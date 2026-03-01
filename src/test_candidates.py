import urllib.request

try:
    with urllib.request.urlopen("http://localhost:8000/gtg") as gtg:
        if gtg.code == 200:
            print("\033[90m\N{CHECK MARK}\033[0m good to go passed")
        else:
            raise Exception
except Exception as ex:
    print("\033[91m\N{BALLOT X}\033[0m good to go failed:", ex.reason)


try:
    with urllib.request.urlopen(
        "http://localhost:8000/candidate/John%20Smith", data=b"test"
    ) as insert:
        if insert.code == 200:
            print("\033[90m\N{CHECK MARK}\033[0m insert passed")
        else:
            raise Exception
except Exception as ex:
    print("\033[91m\N{BALLOT X}\033[0m insert failed:", ex.reason)


try:
    with urllib.request.urlopen(
        "http://localhost:8000/candidate/John%20Smith"
    ) as verify:
        if verify.code == 200:
            print("\033[90m\N{CHECK MARK}\033[0m verification passed")
        else:
            raise Exception(code=verify.code)
except Exception as ex:
    print("\033[91m\N{BALLOT X}\033[0m verification failed:", ex.reason)

try:
    with urllib.request.urlopen("http://localhost:8000/candidates") as list:
        if list.code == 200:
            print("\033[90m\N{CHECK MARK}\033[0m candidate list passed")
        else:
            raise Exception
except Exception as ex:
    print("\033[91m\N{BALLOT X}\033[0m candidate list failed:", ex.reason)
