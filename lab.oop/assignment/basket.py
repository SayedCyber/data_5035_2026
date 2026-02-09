from __future__ import annotations
from collections import UserList
from decimal import Decimal

class Basket(UserList):
    """A list-like cart with guardrails.

    Only add via add_line(sku, qty, price). Uses Decimal for money.

    >>> b = Basket(); b.add_line('TEE', 2, Decimal('10.00')); b.total()
    Decimal('20.00')
    """
    def add_line(self, sku: str, qty: int, price: Decimal) -> None:
        # TODO: validate sku non-empty, qty>0, price>=0 then append tuple
        raise NotImplementedError

    def total(self) -> Decimal:
        # TODO: sum qty*price as Decimal
        raise NotImplementedError

    def __setitem__(self, i, item):
        raise TypeError('use add_line()')

    def insert(self, i, item):
        raise TypeError('use add_line()')
