#include <iostream>
#include <pybind11/pybind11.h>
namespace py = pybind11;
constexpr auto pyref =
    py::return_value_policy::reference; // object lifetime is managed on C++
                                        // side
// Note: declare pointer & base class;
// use reference policy when python shouldn't destroy returned object
PYBIND11_MODULE(py_test, m)
{
    m.doc() = "Python test"; // optional module docstring
    m.def("print_vector3", [](float x, float y, float z) {
        std::cout << "number from cpp: " << x << ' ' << y << ' ' << z << "\n";
    });
}