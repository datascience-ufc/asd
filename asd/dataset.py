import pandas as pd
from asd import config
from os import path


def autism():
    p = path.join(config.data_path, "dataset.csv")
    return pd.read_csv(p)


def basicResourceEngineering(data):
    # Input: Dataset
    # Output: Independent and Dependent variable, respectively.
    # The independent variables are filtered and the dependent
    # variable recoded.
    attributes = ["A{}_Score".format(n) for n in range(1, 11)]
    data["Class/ASD"] = data["Class/ASD"].replace(
        {"NO": 0, "YES": 1}
    )
    return data[attributes], data["Class/ASD"]
