#!/usr/bin/env python3
try:
    import av
    print(f"av version: {av.__version__}")
    ver = av.__version__.split(".")
    if int(ver[0]) < 14:
        print("ERROR: av version too old, need 14.2+")
    elif int(ver[0]) == 14 and int(ver[1]) < 2:
        print("ERROR: av version too old, need 14.2+")
    else:
        print("OK: av version meets requirements")
except ImportError as e:
    print(f"ERROR: Could not import av: {e}")
