from __future__ import annotations
from abc import ABC, abstractmethod
from math import sqrt, radians, sin, cos, asin
from typing import Tuple

Point = Tuple[float, float]

class Distance(ABC):
    @abstractmethod
    def between(self, a: Point, b: Point) -> float: ...

class Euclidean(Distance):
    def between(self, a: Point, b: Point) -> float:
        # We calculate the straight line distance like a ruler.
        # Step 1: Find the difference between x points and y points.
        x_difference = a[0] - b[0]
        y_difference = a[1] - b[1]
        
        # Step 2: Use the formula: square root of (x^2 + y^2).
        sum_of_squares = (x_difference**2) + (y_difference**2)
        return sqrt(sum_of_squares)

class Manhattan(Distance):
    def between(self, a: Point, b: Point) -> float:
        # This is like walking in a city grid where you can't go diagonally.
        # We just add the absolute differences of x and y.
        x_dist = abs(a[0] - b[0])
        y_dist = abs(a[1] - b[1])
        return x_dist + y_dist

class GreatCircle(Distance):
    """Treat points as (lat, lon) in degrees; return km (R=6371.0088)."""
    def between(self, a: Point, b: Point) -> float:
        # This calculates the distance on a curved surface like Earth.
        # First, we convert the degrees into radians.
        lat1, lon1 = radians(a[0]), radians(a[1])
        lat2, lon2 = radians(b[0]), radians(b[1])
        
        # We find the difference between the latitudes and longitudes.
        diff_lat = lat2 - lat1
        diff_lon = lon2 - lon1
        
        # This is the Haversine formula broken into smaller steps.
        # It looks complex, but it's just math for a sphere.
        a_value = sin(diff_lat / 2)**2 + cos(lat1) * cos(lat2) * sin(diff_lon / 2)**2
        earth_radius = 6371.0088 # Provided radius in KM
        
        # Final result using the arcsine function.
        distance_km = 2 * earth_radius * asin(sqrt(a_value))
        return distance_km

def compare_profiles(metric: Distance, a: Point, b: Point) -> float:
    # This is Polymorphism: the 'metric' can be any of the classes above.
    # We don't need to know which one; we just call .between().
    return metric.between(a, b)