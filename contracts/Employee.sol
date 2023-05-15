// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

/// @notice data modeling using employee struct
struct employee {
    address identifier;
    string name;
    uint8 age;
    string email;
    ContactAddress contact;
}

/// @notice data modeling using ContactAddress struct
struct ContactAddress {
    string city;
    string state;
}

/// @notice Employee contract
contract Employee {
    mapping(address => employee) allEmployees;
    address[] employeeReference;

    /// @notice add an employee
    function AddEmployee(address _identifier, string memory _name,
    uint8 _age, string memory _email, string memory _state,
    string memory _city) external returns (bool){
        ContactAddress memory contactAdd = ContactAddress(
            _city, _state
        );
        allEmployees[_identifier].identifier = _identifier;
        allEmployees[_identifier].name= _name;
        allEmployees[_identifier].age = _age;
        allEmployees[_identifier].email = _email;
        allEmployees[_identifier].contact = contactAdd;
        employeeReference.push(_identifier);
        return true;
    }

    /// @notice get an employee
    function GetAnEmployee(address _identifier) external view returns (
        string memory _name, uint8 _age, string memory _email,
        string memory _city, string memory _state
    ){
        employee memory temp = allEmployees[_identifier];
        _name = temp.name;
        _age = temp.age;
        _email = temp.email;
        ContactAddress memory contactAddress = temp.contact;
        _city = contactAddress.city;
        _state = contactAddress.state;

    }

    /// @notice update an employee
    function UpdateEmployee(address _identifier, string memory _name,
        uint8 _age, string memory _email, string memory _state,
        string memory _city) external returns (bool){
            ContactAddress memory contractAdd = ContactAddress(
                _city, _state
            );
            allEmployees[_identifier].identifier = _identifier;
            allEmployees[_identifier].name = _name;
            allEmployees[_identifier].age = _age;
            allEmployees[_identifier].email = _email;
            allEmployees[_identifier].contact = contractAdd;
            return true;
        }

    /// @notice get all employees
    function GetAllEmployee(uint startRecord, uint endRecord) external view
        returns (string[] memory, uint8[] memory, string[] memory, 
        address[] memory, string[] memory, string[] memory){
            uint8[] memory _age = new uint8[] (employeeReference.length);
            string[] memory _name = new string[] (employeeReference.length);
            string[] memory _email = new string[] (employeeReference.length);
            address[] memory _identifier = new address[] (employeeReference.length);
            string[] memory _state = new string[] (employeeReference.length);
            string[] memory _city = new string[] (employeeReference.length);
            for(uint i = startRecord; i <= endRecord; i++){
                address addressInArray = employeeReference[i-1];
                _age[i-1] = allEmployees[addressInArray].age;
                _name[i-1] = allEmployees[addressInArray].name;
                _email[i-1] = allEmployees[addressInArray].email;
                _identifier[i-1] = allEmployees[addressInArray].identifier;
                _state[i-1] = allEmployees[addressInArray].contact.state;
                _city[i-1] = allEmployees[addressInArray].contact.city;
            }
            return (_name, _age, _email, _identifier, _state, _city);
        }
}

