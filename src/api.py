"""API implementation for the Resume Markdown to DOCX converter application."""

import argparse
import copy
import json
import logging
import os
import tempfile
import textwrap
import urllib
import uuid
from io import BytesIO
from pathlib import Path
from typing import Any, ClassVar

import yaml
from flask import Flask, request
from flask.wrappers import Response
from flask_restful import reqparse
from flask_restful_swagger_3 import (
    Api,
    Resource,
    Schema,
    get_swagger_blueprint,
    swagger,
)
from werkzeug.datastructures import FileStorage

try:
    import api_utils
    from resume_md_to_docx import (
        DEFAULT_OUTPUT_DIR,
        DEFAULT_OUTPUT_FORMAT,
        DOCX_EXTENSION,
        PDF_EXTENSION,
        ConfigLoader,
        convert_to_pdf,
        create_ats_resume,
    )
except ImportError:
    from src import api_utils
    from src.resume_md_to_docx import (
        DEFAULT_OUTPUT_DIR,
        DEFAULT_OUTPUT_FORMAT,
        DOCX_EXTENSION,
        PDF_EXTENSION,
        ConfigLoader,
        convert_to_pdf,
        create_ats_resume,
    )

# To be able to run as `python src/api.py` (or `python3 api.py`):
# if __name__ == "__main__":
#     from resume_md_to_docx import *
# else:
#     from src.resume_md_to_docx import *

logging.basicConfig(
    level=logging.INFO,
    datefmt="%Y-%m-%d %H:%M:%S",
    format="%(asctime)s.%(msecs)d %(levelname)-8s "
    "[%(processName)s] [%(threadName)s] %(filename)s:%(funcName)s:%(lineno)d --- %(message)s",
)

SCRIPT_DIR = Path(__file__).parent
API_CONFIG_FILE = Path(os.environ.get("API_CONFIG_FILE", "api_config.yaml"))


class ApiConfig:
    """Application configuration class"""

    def __init__(self, api_config_file: Path) -> None:
        """Initialize the application configuration

        Args:
            api_config_file (Path): Path to the API configuration file

        """
        self._config_file = api_config_file
        self._config_file_realpath = api_config_file.absolute().resolve()
        self._config = self.load_app_config()

        # Required settings
        self._server = self._config.get("server")

    @property
    def config_file(self) -> Path:
        """Get document default settings

        Returns:
            dict: Document defaults configuration

        """
        return Path(self._config_file)

    @property
    def config_file_realpath(self) -> Path:
        """Get document default settings

        Returns:
            dict: Document defaults configuration

        """
        return Path(self._config_file_realpath)

    @property
    def config(self) -> dict:
        """Get the entire configuration dictionary

        Returns:
            dict: Complete configuration dictionary

        """
        return self._config

    @property
    def server(self) -> str:
        """Get the server name for the API

        Returns:
            str: Server name for the API

        """
        return self._server

    @property
    def mimetypes(self) -> dict[str, list[str]]:
        """Get mimetypes settings

        Returns:
            dict: Mimetypes configuration

        """
        return self._config.get("mimetypes", {})

    @property
    def cors(self) -> dict:
        """Get cors settings

        Returns:
            dict: Cors configuration

        """
        return self._config.get("cors", {})

    @property
    def logging(self) -> dict:
        """Get logging settings

        Returns:
            dict: Logging configuration

        """
        return self._config.get("logging", {})

    @property
    def input(self) -> dict:
        """Get input settings

        Returns:
            dict: Input configuration

        """
        return self._config.get("input", {})

    @property
    def output(self) -> dict:
        """Get output settings

        Returns:
            dict: Output configuration

        """
        return self._config.get("output", {})

    # Load API configuration
    def load_app_config(self) -> dict[str, Any]:
        """Load API configuration from api_config.yaml

        Returns:
            dict: Application configuration

        """
        if self._config_file_realpath.exists():
            try:
                with self._config_file_realpath.open(
                    encoding="utf-8",
                    errors="replace",
                ) as f:
                    return yaml.safe_load(f)
            except Exception as e:
                print(f"Error loading app config: {e}")
                return {}
        else:
            print(f"Warning: {self._config_file_realpath} not found, using defaults")
            return {}


class BaseApi:
    """Base class for Flask application"""

    def __init__(self, api_config_file: Path) -> None:
        """Initialize the API Base

        Args:
            api_config_file (Path): Path to the API configuration file

        """
        # Load application configuration
        api_config = ApiConfig(api_config_file)

        # Create Flask application
        flask_app = Flask(__name__.split(".", maxsplit=1)[0])

        self._app = flask_app
        self._api_config = api_config
        self._api = Api(
            flask_app,
            title="Resume Markdown to DOCX API",
            description="API for converting markdown resumes to ATS-friendly formats",
            version="1.0",
            swagger_prefix_url="/api/doc",
        )

        self._host = self._api_config.server.get("host")
        self._port = self._api_config.server.get("port")
        # self._app.config["SERVER_NAME"] = f"{self._host}:{self._port}"

        self._app.logger.debug(f"API host: {self._host}")
        self._app.logger.debug(f"API port: {self._port}")
        self._app.logger.debug(f"API mimetypes: {self._api_config.mimetypes}")
        self._app.logger.debug(f"API cors: {self._api_config.cors}")
        self._app.logger.debug(f"API output: {self._api_config.output}")

        self._configure_logging()
        self._configure_cors()

    @property
    def app(self) -> Flask:
        """Get the Flask application instance

        Returns:
            Flask: Flask application instance

        """
        return self._app

    @property
    def api(self) -> Api:
        """Get the API instance

        Returns:
            Api: API instance

        """
        return self._api

    @property
    def api_config(self) -> ApiConfig:
        """Get the API configuration instance

        Returns:
            ApiConfig: API configuration instance

        """
        return self._api_config

    @property
    def host(self) -> str:
        """Get the host for the API

        Returns:
            str: Host for the API

        """
        return self._host

    @property
    def port(self) -> int:
        """Get the port for the API

        Returns:
            int: Port for the API

        """
        return self._port

    def run(
        self,
        program_description: str | None = None,
        epilog_text: str | None = None,
    ) -> None:
        """Run the Flask application

        Args:
            program_description (str | None): Description of the program
            epilog_text (str | None): Epilog text for the help message

        """
        # Parse command line arguments with enhanced help
        parser = argparse.ArgumentParser(
            description=program_description,
            epilog=epilog_text,
            formatter_class=argparse.RawDescriptionHelpFormatter,
        )

        parser.add_argument(
            "-c",
            "--config",
            dest="config_file",
            help="Path to YAML configuration file",
            default=self._api_config.config_file,
        )

        parser.add_argument(
            "--debug",
            action="store_true",
            dest="debug",
            help="Enable debug mode for the Flask application",
            default=False,
        )

        args = parser.parse_args()

        self._app.debug = args.debug
        self._app.run()

    def _configure_logging(self) -> None:
        """Configure logging for the API"""
        log_level_name = self._api_config.logging.get("level", "INFO")
        self._app.logger.setLevel(getattr(logging, log_level_name))
        self._app.logger.info(f"Logging level set to {log_level_name}")

    def _configure_cors(self) -> None:
        """Configure CORS for the API"""
        # Configure CORS if enabled
        cors_config = self._api_config.cors
        if self._api_config.cors.get("enabled", False):
            from flask_cors import CORS

            self._app.logger.info(f"Configuring CORS with: {cors_config}")
            CORS(
                self._app,
                resources={
                    r"/convert/*": {
                        "origins": cors_config.get("origins", "*"),
                        "expose_headers": cors_config.get(
                            "expose_headers",
                            ["Content-Disposition"],
                        ),
                    },
                },
                supports_credentials=cors_config.get("supports_credentials", "*"),
            )
        else:
            self._app.logger.info("CORS disabled")


class ErrorSchema(Schema):
    """Schema for error responses"""

    type: ClassVar[str] = "object"
    properties: ClassVar[dict] = {
        "success": {
            "type": "boolean",
            "description": "Whether the operation was successful",
        },
        "message": {"type": "string", "description": "Status message"},
    }


class App(BaseApi):
    """API class for handling resume conversion"""

    def __init__(self, api_config_file: Path) -> None:
        """Initialize the API

        Args:
            app (Flask): Flask application instance
            api_config (ApiConfig): Application configuration instance

        """
        super().__init__(api_config_file)

        self._file_parser = reqparse.RequestParser()
        self._file_parser.add_argument(
            "input_file",
            location="files",
            type=FileStorage,
            required=False,
            help="Markdown resume file",
        )
        self._file_parser.add_argument(
            "config_options",
            type=str,
            location="form",
            required=False,
            help="JSON string with configuration overrides",
        )

    @property
    def file_parser(self) -> reqparse.RequestParser:
        """Get the file/form request parser

        Returns:
            RequestParser: The request parser instance

        """
        return self._file_parser

    def _check_extension(
        self,
        expected_extension: str,
        filename: Path | None = None,
    ) -> bool:
        """Check if the file has a valid extension

        Args:
            expected_extension (str): Expected file extension
            filename (Path | None): File name to check

        Returns:
            bool: True if the file has a valid extension, False otherwise

        Raises:
            ValueError: If the file extension is invalid

        """
        # Check if the file has a valid extension
        if filename and filename.suffix != f".{expected_extension}":
            msg = f"Invalid file extension: .{expected_extension} is expected"
            raise ValueError(
                msg,
            )
        return True

    def error_response(
        self,
        code: int,
        error: object,
        message: str | None = None,
    ) -> tuple[dict[str, Any], int]:
        """Return a JSON error response

        Args:
            message (str | None): Error message to return
            level (int): HTTP status code

        Returns:
            tuple: JSON response with error message and status code

        """
        msg = f"{message}: {error!s}" if message else str(error)
        self._app.logger.error(msg)
        return {
            "success": False,
            "message": msg,
        }, code

    def _response(
        self,
        md_input_path: Path,
        docx_output_path: Path,
        output_formats: list[str],
        config_loader: ConfigLoader,
    ) -> Response:
        """Convert markdown resume to DOCX and optionally PDF

        Args:
            md_input_path (Path): Path to the input markdown file
            docx_output_path (Path): Path to the output DOCX file
            output_formats (list[str]): List of output formats
            config_loader (ConfigLoader): Configuration loader instance
            uuid_name (str): UUID of the input file (if applicable)

        Returns:
            Response: Flask response with the generated file

        """
        self._app.logger.info(f"Markdown input file: {md_input_path}")
        self._app.logger.info(f"Docx output file: {docx_output_path}")

        try:
            self._api_config.mimetypes.get("docx")
            self._api_config.mimetypes.get("pdf")

            # Convert markdown to DOCX
            docx_path = create_ats_resume(
                md_input_path,
                docx_output_path,
                config_loader=config_loader,
            )

            # Track created files and file to return
            output_file = None
            mime_types = None

            # Process DOCX if requested
            if DOCX_EXTENSION in output_formats:
                self._app.logger.info(f"Output extension: {DOCX_EXTENSION}")
                if Path(docx_path).exists():
                    output_file = docx_path
                    mime_types = self._api_config.mimetypes.get("docx")

            # Process PDF if requested (convert from the generated DOCX)
            elif PDF_EXTENSION in output_formats:
                self._app.logger.info(f"Output extension: {PDF_EXTENSION}")
                pdf_path = convert_to_pdf(docx_path)
                if pdf_path and Path(pdf_path).exists():
                    self._app.logger.info(f"PDF conversion successful: {pdf_path}")
                    output_file = pdf_path
                    mime_types = self._api_config.mimetypes.get("pdf")

            else:
                msg = "Invalid output format specified"
                raise ValueError(msg)

            output_file_path = Path(output_file)

            # If we don't have a file to return, that's an error
            self._app.logger.info(f"Output file: {output_file_path}")
            if not output_file or not output_file_path.exists():
                msg = f"Failed to generate output file: {output_file_path}"
                raise Exception(msg)

            download_name = output_file_path.name
            self._app.logger.info(f"Successfully created: {output_file_path}")

            # Read file into memory before temp dir is cleaned up
            if True:
                from flask import send_file

                with output_file_path.open("rb") as f:
                    file_data = BytesIO(f.read())

                return send_file(
                    file_data,
                    as_attachment=True,
                    download_name=download_name,
                    mimetype=mime_types[0],
                )
            # else:
            #     from flask import send_from_directory

            #     # Return the appropriate file directly from the temp directory
            #     # Add explicit filename in Content-Disposition header for curl -O
            #     # Existing behavior - direct file download
            #     response = send_from_directory(
            #         directory=docx_output_path.parent,
            #         path=output_file_path.name,
            #         as_attachment=True,
            #         download_name=download_name,
            #         mimetype=mime_types[0],
            #     )

            #     # Force proper filename in Content-Disposition header
            #     response.headers["Content-Disposition"] = (
            #         f'attachment; filename="{download_name}"'
            #     )

            #     return response

        except ValueError as e:
            return self.error_response(400, f"Value error: {e!s}")
        except FileNotFoundError as e:
            return self.error_response(404, e, "File not found")
        except Exception as e:
            return self.error_response(400, f"Error: {e!s}")

    def post(
        self,
        output_format: str = DEFAULT_OUTPUT_FORMAT,
        request_body: str | None = None,
    ) -> Response | tuple[dict[str, Any], int]:
        """Convert markdown resume to DOCX and optionally PDF

        Args:
            output_format (str): Output format to generate (docx or pdf)
            request_body (str | None): Raw markdown content from request body

        Returns:
            Response: Flask response with the generated file

        """
        # Always load the config
        config_loader = ConfigLoader()

        # Get the uploaded file and parameters
        args = self._file_parser.parse_args()
        input_file = args["input_file"]
        output_formats = (
            [output_format] if isinstance(output_format, str) else output_format
        )

        # Determine input source based on config and available inputs
        prefer_file = self._api_config.input.get("prefer_file", True)
        use_file_input = input_file is not None and (
            prefer_file or request_body is None
        )

        self._app.logger.info(f"Using file input: {use_file_input}")
        self._app.logger.info(f"Using request body: {request_body is not None}")
        self._app.logger.info(f"Request body: {request_body}")
        self._app.logger.info(f"Input file: {input_file}")

        if not use_file_input and not request_body:
            return self.error_response(
                400,
                ValueError("No input provided"),
                "Either input_file or request body must be provided",
            )

        # Get filename and output name
        if use_file_input:
            input_filename = Path(input_file.filename)
        else:
            random_id = uuid.uuid4().hex
            input_filename = Path(random_id).with_suffix(".md")

        base_output_filename = input_filename.stem
        output_name = f"{base_output_filename}.{DOCX_EXTENSION}"

        # Parse config_options if provided
        config_data = {}
        if args["config_options"]:
            try:
                config_data = json.loads(args["config_options"])
            except json.JSONDecodeError as e:
                return self.error_response(
                    400,
                    e,
                    "Invalid JSON in config_options parameter",
                )

        self._resolve_config_helper(config_loader, config_data)
        self._app.logger.debug(f"Configuration loaded: {config_loader.config}")
        temp_dir_enabled = self._api_config.output.get("use_temp_directory", True)
        self._app.logger.info(f"Temporary directory enabled: {temp_dir_enabled}")

        if temp_dir_enabled:
            with tempfile.TemporaryDirectory() as temp_dir:

                # Save the uploaded file
                temp_input_path = Path(temp_dir) / input_filename

                if use_file_input:
                    # Save the uploaded file
                    input_file.save(temp_input_path)
                else:
                    # Write the input text to a file, preserving non-UTF-8 characters
                    try:
                        # First try UTF-8
                        with temp_input_path.open("w", encoding="utf-8") as f:
                            f.write(request_body)
                    except UnicodeEncodeError:
                        # If that fails, write binary
                        self._app.logger.info(
                            "UTF-8 encoding failed, writing as binary",
                        )
                        with temp_input_path.open("wb") as f:
                            f.write(request_body.encode("utf-8", errors="replace"))

                # Prepare output paths directly in the temporary directory
                temp_output_path = Path(temp_dir) / output_name

                return self._response(
                    temp_input_path,
                    temp_output_path,
                    output_formats,
                    config_loader,
                )
        else:
            output_path = DEFAULT_OUTPUT_DIR / output_name
            return self._response(
                input_filename,
                output_path,
                output_formats,
                config_loader,
            )

    def _resolve_config_helper(
        self,
        config_loader: ConfigLoader,
        config_options: dict[str, Any] | None = None,
    ) -> None:
        """Merge the provided config options with the existing config

        Args:
            config_loader (ConfigLoader): Existing config loader
            config_options (dict): Configuration options to merge

        """
        if config_options:
            self._app.logger.info(f"Merging custom configuration: {config_options}")

            # Update top-level config sections
            for section_key, section_values in config_options.items():
                if section_key in config_loader.config:
                    # If section exists in default config, update it
                    if isinstance(section_values, dict) and isinstance(
                        config_loader.config[section_key],
                        dict,
                    ):
                        self._app.logger.debug(
                            f"Merging section '{section_key}' with values: {section_values}",
                        )
                        config_loader.config[section_key].update(section_values)
                    else:
                        # Replace the entire section if it's not a mergeable dictionary
                        self._app.logger.debug(
                            f"Replacing section '{section_key}' with values: {section_values}",
                        )
                        config_loader.config[section_key] = section_values
                else:
                    # Add new section if it doesn't exist
                    self._app.logger.debug(
                        f"Adding new section '{section_key}' with values: {section_values}",
                    )
                    config_loader.config[section_key] = section_values


app = App(SCRIPT_DIR / API_CONFIG_FILE)


@app.app.route("/", methods=["GET"])
def default() -> tuple[dict[str, str], int]:
    """Default GET endpoint"""
    return {"status": "invalid request"}, 400


@app.app.route("/gtg", methods=["GET"])
def gtg() -> Response | tuple[dict[str, str], int]:
    """/gtg GET endpoint"""
    try:
        details = request.args.get("details", None)
        if details is not None:
            instance_id = api_utils.get_instance_id(api_utils.health_check_timeout)
            return {"connected": "true", "instance-id": instance_id}, 200
    except urllib.error.HTTPError as e:
        return {"status": str(e.reason)}, e.code
    # pylint: disable=broad-except
    except Exception as e:
        return {"status": str(e)}, 500

    return Response(status=200)


class ConvertDocxResource(Resource):
    """Resource for converting markdown resume to DOCX"""

    @swagger.tags("Convert")
    @swagger.response(200, "Success - Returns DOCX file download", no_content=True)
    @swagger.response(400, "Bad Request", schema=ErrorSchema)
    @swagger.response(404, "File Not Found", schema=ErrorSchema)
    @swagger.response(500, "Server Error", schema=ErrorSchema)
    def post(self) -> Response:
        """Convert markdown resume to DOCX

        You can provide the markdown content either:
        - As a file upload (input_file)
        - Directly in the request body (Content-Type: text/plain)

        Returns:
            Response: Flask response with the generated DOCX file

        """
        content = request.get_data(as_text=True)
        return app.post(output_format=DOCX_EXTENSION, request_body=content)


class ConvertPdfResource(Resource):
    """Resource for converting markdown resume to PDF"""

    @swagger.tags("Convert")
    @swagger.response(200, "Success - Returns PDF file download", no_content=True)
    @swagger.response(400, "Bad Request", schema=ErrorSchema)
    @swagger.response(404, "File Not Found", schema=ErrorSchema)
    @swagger.response(500, "Server Error", schema=ErrorSchema)
    def post(self) -> Response:
        """Convert markdown resume to PDF

        You can provide the markdown content either:
        - As a file upload (input_file)
        - Directly in the request body (Content-Type: text/plain)

        Returns:
            Response: Flask response with the generated PDF file

        """
        content = request.get_data(as_text=True)
        return app.post(output_format=PDF_EXTENSION, request_body=content)


app.api.add_resource(ConvertDocxResource, "/convert/docx")
app.api.add_resource(ConvertPdfResource, "/convert/pdf")

_MARKDOWN_SAMPLE = textwrap.dedent(
    """
# John Q. Doe

*Clever headline to hightlight persona*

Some featured ◆ Specialites ◆ To highlight ◆ At the top


## About
A brief introduction...

## Top Skills
Some top skills • For more • Buzzwords


## Experience

### Name of Company

#### Specific Role Title

**Month Year - Present**

*City, State (or Remote)*

##### Key Skills

These are • The role specific • Skills • For additional • Keywords

##### Summary

Description of role and responsibilities...

- A bullet point
- Another bullet point


## Projects

### Name of Project or Achievement

A brief description...

> ##### **Month Year - Month Year** (Perhaps a location)


## Licenses & certifications

### Name of Certification

> #### Certifying Organization
> [*Issued Mon. Year*](https://www.example.com)


## Education

**Institution Name**
Degree - Major


## Contact

**LinkedIn**
https://www.linkedin.com/in/jonh-q-doe/

**Email**
john.q.doe@example.com

**Phone**
(555) 123-4567
""",
).strip()

# Patch the generated spec to describe multipart/form-data request bodies.
# The library does not support FileStorage type in @swagger.reqparser, so we
# update the live spec dict directly after resource registration.
_FORM_REQUEST_BODY = {
    "content": {
        "multipart/form-data": {
            "schema": {
                "type": "object",
                "properties": {
                    "input_file": {
                        "type": "string",
                        "format": "binary",
                        "description": "Markdown resume file (.md)",
                    },
                    "config_options": {
                        "type": "string",
                        "description": "JSON string with configuration overrides",
                        "example": "",
                    },
                },
            },
        },
        "text/plain": {
            "schema": {
                "type": "string",
                "description": "Raw markdown content",
                "example": _MARKDOWN_SAMPLE,
            },
        },
    },
    "description": "Markdown resume (multipart file upload or raw text body)",
    "required": False,
}
_spec = app.api.open_api_object
for _path in ("/convert/docx", "/convert/pdf"):
    _spec["paths"][_path]["post"]["requestBody"] = copy.deepcopy(_FORM_REQUEST_BODY)


# get_swagger_blueprint has two quirks that require workarounds:
# 1. It re-validates the spec and rejects manually patched inline schemas
#    (validate_schema_object calls validate_reference_object on every dict
#    value, failing anything that isn't a bare {"$ref": "..."}).
#    Fix: temporarily replace the validator with a no-op.
# 2. It reads SWAGGER_BLUEPRINT_URL_PREFIX from current_app.config to set
#    base_url for static asset URLs in the template. Without an active app
#    context it falls back to "", rendering assets as /swagger-ui.css (404).
#    Fix: set the config key and push an app context before calling it.
import flask_restful_swagger_3 as _frs3

app.app.config["SWAGGER_BLUEPRINT_URL_PREFIX"] = "/swagger"
_original_validate = _frs3.validate_open_api_object
_frs3.validate_open_api_object = lambda x: None  # noqa: ARG005
with app.app.app_context():
    swagger_bp = get_swagger_blueprint(
        app.api.open_api_object,
        swagger_prefix_url="/api/doc",
        swagger_url="/swagger.json",
        title="Resume Markdown to DOCX API",
    )
validate_open_api_object = _original_validate
app.app.register_blueprint(swagger_bp, url_prefix="/swagger")


if __name__ == "__main__":

    # Program description and epilog
    _PROGRAM_DESCRIPTION = """
Resume Markdown to DOCX API
--------------------------------
This API converts markdown resumes to ATS-friendly formats (DOCX and PDF).
It provides endpoints for converting markdown files to DOCX and PDF formats.
"""

    _EPILOG_TEXT = """
Example usage:
# Start the API server
python api.py --config api_config.yaml --debug

# Convert a markdown resume to PDF
curl -X POST "http://localhost:3000/convert/pdf" \\
-H "Content-Type: multipart/form-data" \\
-F "input_file=@resume.md" \\
-F "config_options={\"document_styles\": {\"Subtitle\": {\"font_name\": \"Helvetica Neue\"}}}"
"""

    app.run(_PROGRAM_DESCRIPTION, _EPILOG_TEXT)

# Export the Flask application object, not the App class instance
# This is what the wsgi server needs - the actual Flask application
resume_app = app.app  # Get the Flask app from App class instance
