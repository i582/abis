import "@acton/testing/expect"
import "../types/getgems_deployer.types"
import "../wrappers/GetgemsDeployer.gen"

const MAINNET_GETGEMS_DEPLOYER_ADDRESS = "EQAIFunALREOeQ99syMbO6sSzM_Fa1RsPD5TBoS0qVeKQ-AR"
const MAINNET_GETGEMS_DEPLOYER_OWNER_ADDRESS = "EQBYTuYbLf8INxFtD8tQeNk5ZLy-nAX9ahQbG_yl1qQ-GEMS"

fun mainnetGetgemsDeployerStorageFixture(): GetgemsDeployerStorage {
    return GetgemsDeployerStorage {
        ownerAddress: address(MAINNET_GETGEMS_DEPLOYER_OWNER_ADDRESS),
    };
}

get fun `test getgems deployer mainnet storage fixture derives address`() {
    val storage = mainnetGetgemsDeployerStorageFixture();
    val deployer = GetgemsDeployer.fromStorage(storage);
    val decodedStorage = GetgemsDeployerStorage.fromCell(storage.toCell());

    expect(deployer.address).toEqual(address(MAINNET_GETGEMS_DEPLOYER_ADDRESS));
    expect(decodedStorage.ownerAddress).toEqual(address(MAINNET_GETGEMS_DEPLOYER_OWNER_ADDRESS));
}
