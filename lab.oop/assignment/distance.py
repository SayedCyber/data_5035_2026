from __future__ import annotations
from abc import ABC, abstractmethod
from math import sqrt, radians, sin, cos, asin
from typing import Tuple

Point = Tuple[float, float]

class Distance(ABC):
    @abstractmethod
    def between(self, a: Point, b: Point) -> float: ...

class Euclidean(Distance):
    # TODO
    raise NotImplementedError

class Manhattan(Distance):
    # TODO
    raise NotImplementedError

class GreatCircle(Distance):
    """Treat points as (lat, lon) in degrees; return km (R=6371.0088)."""
    # TODO (haversine)
    raise NotImplementedError

def compare_profiles(metric: Distance, a: Point, b: Point) -> float:
    # TODO: delegate to metric
    raise NotImplementedError
