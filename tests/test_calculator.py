"""Tests for Calculator module."""
import pytest
from src.calculator import Calculator


class TestCalculator:
    """Test cases for Calculator class."""

    def setup_method(self):
        """Set up test fixtures."""
        self.calc = Calculator()

    def test_add_positive_numbers(self):
        """Test adding positive numbers."""
        assert self.calc.add(2, 3) == 5

    def test_add_negative_numbers(self):
        """Test adding negative numbers."""
        assert self.calc.add(-2, -3) == -5

    def test_add_mixed_numbers(self):
        """Test adding positive and negative numbers."""
        assert self.calc.add(-2, 3) == 1

    def test_add_floats(self):
        """Test adding floating point numbers."""
        result = self.calc.add(1.5, 2.5)
        assert result == pytest.approx(4.0)

    def test_add_zero(self):
        """Test adding zero."""
        assert self.calc.add(5, 0) == 5
        assert self.calc.add(0, 5) == 5

    def test_history_records_operations(self):
        """Test that operations are recorded in history."""
        self.calc.add(2, 3)
        self.calc.add(4, 5)
        history = self.calc.get_history()
        assert len(history) == 2
        assert "2 + 3 = 5" in history[0]
        assert "4 + 5 = 9" in history[1]

    def test_clear_history(self):
        """Test clearing history."""
        self.calc.add(1, 1)
        self.calc.clear_history()
        assert len(self.calc.get_history()) == 0

    def test_history_is_copy(self):
        """Test that get_history returns a copy."""
        self.calc.add(1, 1)
        history = self.calc.get_history()
        history.append("fake")
        assert len(self.calc.get_history()) == 1


# TODO: Add tests for subtraction
# TODO: Add tests for multiplication
# TODO: Add tests for division
# TODO: Add tests for division by zero
# TODO: Add tests for memory functions
