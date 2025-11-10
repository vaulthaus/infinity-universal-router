// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/console2.sol";
import "forge-std/Script.sol";
import {RouterParameters} from "../src/base/RouterImmutables.sol";
import {UnsupportedProtocol} from "../src/deploy/UnsupportedProtocol.sol";
import {UniversalRouter} from "../src/UniversalRouter.sol";
import {Create3Factory} from "pancake-create3-factory/src/Create3Factory.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

abstract contract DeployUniversalRouter is Script {
    RouterParameters internal params;
    address internal unsupported;
    address internal create3Factory; // from https://github.com/pancakeswap/pancake-create3-factory

    address constant UNSUPPORTED_PROTOCOL = address(0);
    bytes32 constant BYTES32_ZERO = bytes32(0);

    error Permit2NotDeployed();

    // set values for params and unsupported
    function setUp() public virtual;

    function run() external returns (address router) {
        // deployer will the the initial owner of universal router
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        if (params.permit2 == address(0)) revert Permit2NotDeployed();

        // only deploy unsupported if this chain doesn't already have one
        if (unsupported == address(0)) {
            unsupported = address(new UnsupportedProtocol());
            console2.log("UnsupportedProtocol deployed:", unsupported);
        }

        params = RouterParameters({
            permit2: mapUnsupported(params.permit2),
            weth9: mapUnsupported(params.weth9),
            v2Factory: mapUnsupported(params.v2Factory),
            v3Factory: mapUnsupported(params.v3Factory),
            v3Deployer: mapUnsupported(params.v3Deployer),
            v2InitCodeHash: params.v2InitCodeHash,
            v3InitCodeHash: params.v3InitCodeHash,
            stableFactory: mapUnsupported(params.stableFactory),
            stableInfo: mapUnsupported(params.stableInfo),
            infiVault: mapUnsupported(params.infiVault),
            infiClPoolManager: mapUnsupported(params.infiClPoolManager),
            infiBinPoolManager: mapUnsupported(params.infiBinPoolManager),
            v3NFTPositionManager: mapUnsupported(params.v3NFTPositionManager),
            infiClPositionManager: mapUnsupported(params.infiClPositionManager),
            infiBinPositionManager: mapUnsupported(params.infiBinPositionManager)
        });

        logParams();

        address owner = vm.addr(deployerPrivateKey);
        console.log("universal router owner:", owner);

        // Deploy UniversalRouter directly without Create3Factory
        router = address(new UniversalRouter(params));

        console.log("UniversalRouter contract deployed at ", router);

        // Transfer ownership to deployer
        UniversalRouter(payable(router)).transferOwnership(owner);
        console.log("Ownership transferred to:", owner);

        vm.stopBroadcast();
    }

    function logParams() internal view {
        console2.log("permit2:", params.permit2);
        console2.log("weth9:", params.weth9);
        console2.log("v2Factory:", params.v2Factory);
        console2.log("v3Factory:", params.v3Factory);
        console2.log("v3Deployer:", params.v3Deployer);
        console2.log("v2InitCodeHash:");
        console2.logBytes32(params.v2InitCodeHash);
        console2.log("v3InitCodeHash:");
        console2.logBytes32(params.v3InitCodeHash);
        console2.log("stableFactory:", params.stableFactory);
        console2.log("stableInfo:", params.stableInfo);
        console2.log("infiVault:", params.infiVault);
        console2.log("infiClPoolManager:", params.infiClPoolManager);
        console2.log("infiBinPoolManager:", params.infiBinPoolManager);
        console2.log("v3NFTPositionManager:", params.v3NFTPositionManager);
        console2.log("infiClPositionManager:", params.infiClPositionManager);
        console2.log("infiBinPositionManager:", params.infiBinPositionManager);
    }

    function mapUnsupported(address protocol) internal view returns (address) {
        return protocol == address(0) ? unsupported : protocol;
    }
}
