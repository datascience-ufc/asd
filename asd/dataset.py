import pandas as pd
from asd import config
from os import path


def autism():
    p = path.join(config.data_path, 'dataset.csv')
    return pd.read_csv(p)
