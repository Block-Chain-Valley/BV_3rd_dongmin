// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

interface BummyAccessInterface {
    //* BummyAccessControl
    function cooAddress() external view returns(address);
    function setCEO(address _newCEO) external;
    function setCOO(address _newCOO) external;

}