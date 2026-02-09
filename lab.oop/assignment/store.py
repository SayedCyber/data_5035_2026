from __future__ import annotations
from abc import ABC
from decimal import Decimal

class Store(ABC):
    """Base store with corporate policies.

    Contract:
      - sell(basket) -> Decimal (non-negative)
      - return_item(receipt_id, sku) -> list[str] (steps in order)
      - cooperative super() used in overrides
    """
    def __init__(self, *, store_id: str, name: str, **kw):
        super().__init__(**kw)
        self.store_id = store_id
        self.name = name

    def open_doors(self) -> None:
        pass

    def sell(self, basket: 'Basket') -> Decimal:
        total = basket.total()
        if total < 0:
            raise ValueError('negative totals not allowed')
        return total

    def return_item(self, receipt_id: str, sku: str) -> list[str]:
        """Run corporate checks in order.

        Returns steps: ["ID check", "fraud screen"]
        Subclasses may extend via super().
        """
        # TODO: implement corporate checks
        raise NotImplementedError

    def close_register(self) -> None:
        pass


class FlagshipStore(Store):
    """Flagship adds a VIP grace step after corporate checks."""
    def return_item(self, receipt_id: str, sku: str) -> list[str]:
        # TODO: call super then append "VIP grace window"
        raise NotImplementedError


class OutletEligible(Store):
    """Capability: outlet rules (final sale blocks returns)."""
    def __init__(self, **kw):
        super().__init__(**kw)
        self.final_sale_skus: set[str] = set()

    def mark_final_sale(self, sku: str) -> None:
        self.final_sale_skus.add(sku)

    def return_item(self, receipt_id: str, sku: str) -> list[str]:
        steps = super().return_item(receipt_id, sku)
        if sku in self.final_sale_skus:
            steps.append('final sale — blocked')
        return steps


class PopUp(Store):
    """Capability: popup store with lease end date."""
    def __init__(self, *, lease_ends: str, **kw):
        super().__init__(**kw)
        self.lease_ends = lease_ends

    def open_doors(self) -> None:
        super().open_doors()
        # optional: set transient flags


class HolidayPopUp(OutletEligible, PopUp, FlagshipStore):
    """PopUp + Outlet rules + Flagship behavior (diamond via C3 MRO)."""
    pass
