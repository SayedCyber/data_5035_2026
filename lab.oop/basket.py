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
        # Check if SKU is empty. A product must have a name.
        if not sku:
            raise ValueError("Product SKU cannot be empty")
        
        # Quantity must be a positive number.
        if qty <= 0:
            raise ValueError("Quantity must be greater than zero")
            
        # Price cannot be negative. Free items (0.00) are allowed.
        if price < 0:
            raise ValueError("Price cannot be a negative number")
            
        # If all checks pass, we save the data as a tuple.
        self.data.append((sku, qty, price))

    def total(self) -> Decimal:
        # Start the sum at zero using Decimal for money accuracy.
        total_sum = Decimal("0.00")
        
        # Loop through every line in the basket.
        for sku, qty, price in self.data:
            # Multiply quantity by price and add to the total.
            total_sum = total_sum + (qty * price)
            
        return total_sum
# --- IMPORTANT: These guardrails are needed for the tests to pass ---
    def __setitem__(self, i, item):
        # This prevents someone from changing an item directly like b[0] = ...
        raise TypeError('use add_line()')

    def insert(self, i, item):
        # This prevents someone from inserting items without using add_line()
        raise TypeError('use add_line()')