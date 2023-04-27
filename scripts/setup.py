from setuptools import setup

setup(
    name='spot_account_aws',
    version='0.2',
    py_modules=['spot_account_aws'],
    install_requires=[
        'Click',
        'spotinst-sdk2=2.1.10'
    ],
    entry_points='''
        [console_scripts]
        spot_account_aws=spot_account_aws:cli
    ''',
)
