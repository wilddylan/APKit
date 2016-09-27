#!/usr/bin/env python

import sys
assert sys.version >= '2.5', "Requires Python v2.5 or above."
from setuptools import setup

classifiers = [
    "License :: OSI Approved :: BSD License",
    "Programming Language :: Python",
    "Programming Language :: Python :: 2.5",
    "Programming Language :: Python :: 2.6",
    "Programming Language :: Python :: 2.7",
    "Programming Language :: Python :: 3.2",
    "Programming Language :: Python :: 3.3",
    "Topic :: Software Development :: Libraries :: Python Modules",
]

setup(
    name="iap_local_receipt",
    version="0.1.0",
    author="Edwin Fine",
    author_email="me@edfine.io",
    url="https://github.com/SilentCircle/iap-local-receipt",
    description="A library for local verification of Apple in-app receipts.",
    install_requires=[
        "pyasn1",
        "pyasn1_modules",
        "m2crypto",
        ],
    license="BSD",
    classifiers=classifiers,
    packages=["iap_local_receipt"],
    test_suite='iap_local_receipt.tests',
    tests_require=['pep8'],
)
