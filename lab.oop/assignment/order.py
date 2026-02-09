from __future__ import annotations
from dataclasses import dataclass, field
from decimal import Decimal
from .basket import Basket

@dataclass(slots=True)
class Order:
    order_id: str
    channel: str
    basket: Basket
    total: Decimal = field(default=Decimal('0.00'))

    @classmethod
    def from_pos(cls, *, order_id: str, basket: Basket, cashier_id: str) -> 'Order':
        # TODO
        raise NotImplementedError

    @classmethod
    def from_web(cls, *, order_id: str, cart: Basket, user_id: str, address: str) -> 'Order':
        # TODO
        raise NotImplementedError

    @classmethod
    def from_csv_row(cls, row: dict[str, str]) -> 'Order':
        """Parse row like {'order_id':'C001','channel':'csv','lines':'TEE:2:10.00;MUG:1:8.00'}"""
        # TODO
        raise NotImplementedError

    def __repr__(self) -> str:
        return f"Order(id={self.order_id!r}, channel={self.channel!r}, lines={len(self.basket)}, total={self.total})"
