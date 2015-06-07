# -*- coding: utf-8 -*-

def to_bytes(value):
    """
    Convert any value into a byte sequence.

    :param value: The value to be converted
    :return: Byte sequence
    """
    if isinstance(value, str):
        return bytes(source=value, encoding='utf-8', errors='replace')
    elif isinstance(value, bytearray):
        return bytes(value)
    elif isinstance(value, bytes):
        return value
    elif not value:
        return b''
    else:
        return bytes(source=str(value), encoding='utf-8', errors='replace')

def to_str(value):
    """
    Convert any value into a string.

    :param value: The value to be converted
    :return: Resulting string
    """
    if isinstance(value, bytes) or isinstance(value, bytearray):
        return value.decode(encoding='utf-8', errors='replace')
    elif value is None:
        return ''
    else:
        return str(value)
