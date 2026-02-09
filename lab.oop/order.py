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
        # This is for orders made at the physical store register
        # We just return a new Order with 'pos' as the channel
        return cls(order_id=order_id, channel="pos", basket=basket, total=basket.total())

    @classmethod
    def from_web(cls, *, order_id: str, cart: Basket, user_id: str, address: str) -> 'Order':
        # This is for online orders
        return cls(order_id=order_id, channel="web", basket=cart, total=cart.total())

    @classmethod
    def from_csv_row(cls, row: dict[str, str]) -> 'Order':
        """Parse row like {'order_id':'C001','channel':'csv','lines':'TEE:2:10.00;MUG:1:8.00'}"""
        # This is for reading from a text file (CSV)
        # The row looks like: {'order_id':'C001', 'lines':'TEE:2:10.00;MUG:1:8.00'}
        new_basket = Basket()
        
        # We split the 'lines' string into separate items
        line_strings = row["lines"].split(";")
        
        for s in line_strings:
            # Each s is like 'TEE:2:10.00'
            parts = s.split(":")
            if len(parts) != 3:
                raise ValueError("The CSV row is not formatted correctly")
                
            name = parts[0]
            amount = int(parts[1])
            cost = Decimal(parts[2])
            new_basket.add_line(name, amount, cost)
            
        return cls(order_id=row["order_id"], channel="csv", basket=new_basket, total=new_basket.total())

    def __repr__(self) -> str:
        return f"Order(id={self.order_id!r}, channel={self.channel!r}, lines={len(self.basket)}, total={self.total})"
