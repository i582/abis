import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/testing/expect"
import "../types/payment_channel.types"

const PAYMENT_CHANNEL_CODE_BOC = "data/payment_channels/async/testdata/AsyncPaymentChannel.boc"
const PAYMENT_CHANNEL_CODE_HASH = 0x41f5b77f02d4a96eb465197215ed00923720a6c731fa32934f9c0e80ffb85589
const PAYMENT_CHANNEL_DATA_HASH = 0xf3f4ae36eecc9a939686bba83f36fdbd9b499eca64f5857dac3a249e304f55a0
const PAYMENT_CHANNEL_MAINNET_DATA_BOC = "te6ccgEBAwEArwACswB4XIKPsDBq/cW/D+ZA2copbGXULcBHWGSgFl5LFcyK0XQWrkHtvbnxmkaEd6+5IV2cA8CTRVkW24ftEu+JBDbiop72lTdLwYVpYe3AEFHuRoAAADIAAAAAoAECABEAAAAAAAAAAAgAhwgAepzTnvjobeOMub5Ux5GwEZ+nijgi2ddg51jsJwXIm+0ADjgm0ftAY/BpzLbr1wzeOBLEsyhIR7Et3cUjg/HQOUbg"
const PARTY_A_DESTINATION = "0:3D4E69CF7C7436F1C65CDF2A63C8D808CFD3C51C116CEBB073AC761382E44DF6"
const PARTY_B_DESTINATION = "0:38E09B47ED018FC1A732DBAF5C3378E04B12CCA1211EC4B777148E0FC740E51B"

get fun `test payment channel compiled code fixture is canonical`() {
    val rawCodeBoc = fs.readBytes(PAYMENT_CHANNEL_CODE_BOC);

    expect(rawCodeBoc).toBeNotNull();
    expect(build("AsyncPaymentChannel", PAYMENT_CHANNEL_CODE_BOC).hash()).toEqual(
        PAYMENT_CHANNEL_CODE_HASH,
    );
}

get fun `test payment channel decodes real mainnet storage`() {
    val data = parseCellFromBase64(PAYMENT_CHANNEL_MAINNET_DATA_BOC);
    val storage = AsyncPaymentChannelStorage.fromCell(data);
    val closingConfig = AsyncPaymentChannelClosingConfig.fromCell(storage.closingConfig);
    val paymentConfig = AsyncPaymentChannelPaymentConfig.fromCell(storage.paymentConfig);

    expect(data.hash()).toEqual(PAYMENT_CHANNEL_DATA_HASH);
    expect(storage.inited).toBeFalse();
    expect(storage.balanceA).toEqual(0);
    expect(storage.balanceB).toEqual(0);
    expect(storage.keyA).toEqual(
        0xf0b9051f6060d5fb8b7e1fcc81b39452d8cba85b808eb0c9402cbc962b9915a2,
    );
    expect(storage.keyB).toEqual(
        0xe82d5c83db7b73e3348d08ef5f7242bb380781268ab22db70fda25df12086dc5,
    );
    expect(storage.channelId).toEqual(92038272110415228469469388800325311629);
    expect(storage.committedSeqnoA).toEqual(100);
    expect(storage.committedSeqnoB).toEqual(1);
    expect(storage.quarantine).toBeNull();

    expect(closingConfig.quarantineDuration).toEqual(0);
    expect(closingConfig.misbehaviorFine).toEqual(0);
    expect(closingConfig.conditionalCloseDuration).toEqual(0);

    expect(paymentConfig.excessFee).toEqual(0);
    expect(paymentConfig.destinationA.castToInternal()).toEqual(address(PARTY_A_DESTINATION));
    expect(paymentConfig.destinationB.castToInternal()).toEqual(address(PARTY_B_DESTINATION));
}
