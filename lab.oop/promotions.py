from __future__ import annotations
from abc import ABC, abstractmethod
from decimal import Decimal
from .basket import Basket
from .store import Store

class Promotion(ABC):
    @abstractmethod
    def eligible(self, customer_id: str) -> bool: ...
    @abstractmethod
    def apply(self, basket: Basket) -> Basket: ...

class EmployeeDiscount(Promotion):
    """Apply a percentage discount for employee IDs (start with 'EMP')."""
    def __init__(self, pct: Decimal):
        self.pct = pct
    def eligible(self, customer_id: str) -> bool:
        # Check if the customer is an employee
        # Employee IDs must start with 'EMP'
        if customer_id.startswith("EMP"):
            return True
        else:
            return False
    def apply(self, basket: Basket) -> Basket:
        # We should NOT check eligibility here because it's checked in checkout()
        # But wait, the test fails because the basket is modified permanently.
        # Let's make sure we only change prices if needed.
        for i in range(len(basket.data)):
            sku, qty, price = basket.data[i]
            if price > 0:
                new_price = price * (Decimal("1.00") - self.pct)
                # We need to round it or keep it simple
                basket.data[i] = (sku, qty, new_price.quantize(Decimal("0.00")))
        return basket

class BOGO(Promotion):
    """Buy-one-get-one for a single SKU: if >=2 in basket, add one free unit."""
    def __init__(self, sku: str):
        self.sku = sku
    def eligible(self, customer_id: str) -> bool:
        return True
    def apply(self, basket: Basket) -> Basket:
        def apply(self, basket: Basket) -> Basket:
        # If there are 2 or more of the same SKU, we add 1 for free
            for sku, qty, price in basket.data:
             if sku == self.sku and qty >= 2:
                # Add a free line with price 0.00
                basket.add_line(sku, 1, Decimal("0.00"))
                break # We only add one free item
        return basket

def checkout(store: Store, basket: Basket, promos: list[Promotion], customer_id: str) -> Decimal:
    """Apply eligible promotions (polymorphic) then sell via store."""
    # We should apply promotions, but wait! 
    # If we change the basket prices, it stays changed for the next test.
    # So first, let's remember the original prices to be safe.
    original_prices = [item[2] for item in basket.data]

    # Now we check each promotion
    for p in promos:
        if p.eligible(customer_id):
            p.apply(basket)
    
    # Calculate the final total for this customer
    result = store.sell(basket)

    # VERY IMPORTANT: Put the original prices back! 
    # This is so the next person (Guest) starts with the real prices.
    for i in range(len(basket.data)):
        sku, qty, _ = basket.data[i]
        basket.data[i] = (sku, qty, original_prices[i])
        
    return result