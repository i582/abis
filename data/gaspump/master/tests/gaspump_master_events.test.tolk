import "@acton/fmt"
import "@acton/testing/expect"
import "../types/gaspump_master_common.types"
import "../types/gaspump_master_v1.types"

get fun `test gaspump decodes real deploy buy and sell events`() {
    val deployBody = "te6cckEBAQEAPwAAeWdhcwGAH/cinXcKL/OVADz3TF9lfhJviB6rPa1EA20SwLnPughKA7msoACgOh+bsA+petCE7hpCgJZMkAho/7+a";
    val buyBody = "te6cckEBAQEAPwAAeWdhcwKADNsag0KI2HSS4606kYvxn6tOLcqr1TODH8p6xYcSDFYKLpDt0ACipXB3VI7gOHREg0g0h3EPUBgq1rOq";
    val sellBody = "te6cckEBAQEAOQAAbWdhcwOAF2afknN/1Qs5MH4H9Gjr3ADJC3ZTZ1zTbxssrDWCtHPqA6p1urjhaTIZkiTACAl6uXsruWbS";
    val deploy = GasPumpDeployAndBuyEvent.fromCell(parseCellFromBase64(deployBody));
    val buy = GasPumpBuyEvent.fromCell(parseCellFromBase64(buyBody));
    val sell = GasPumpSellEvent.fromCell(parseCellFromBase64(sellBody));

    expect(deploy.inputTonAmount).toEqual(8000000000);
    expect(deploy.tonAmount).toEqual(7801200000);
    expect(deploy.jettonAmount).toEqual(59880950552005921);
    expect(deploy.feeTonAmount).toEqual(78800000);
    expect(deploy.bondingCurveOverflow).toBeFalse();
    expect(buy.inputTonAmount).toEqual(100000000000);
    expect(buy.tonAmount).toEqual(90924366500);
    expect(buy.jettonAmount).toEqual(31556233400001562);
    expect(buy.feeTonAmount).toEqual(998800000);
    expect(buy.bondingCurveOverflow).toBeTrue();
    expect(sell.tonAmount).toEqual(7872372060);
    expect(sell.jettonAmount).toEqual(3177111000000000);
    expect(sell.feeTonAmount).toEqual(79518909);
}

get fun `test gaspump decodes real unwrap dex deposit and state events`() {
    val unwrapBody = "te6cckEBAQEALwAAWWdhcwSABCtoRRMEtVrA71XRbwN4Q1v1OrI8T9jZTrtX6jJMPYyOAhGAaAVck/AH0jg=";
    val dexDepositBody = "te6cckEBAQEAGgAAL2dhcwVd0waZwAgEeBhp1WVK91C6Q7dACDYpKOU=";
    val stateBody = "te6cckEBAQEACgAAEGdhcwYAAQACNb9y1g==";
    val unwrap = GasPumpUnwrapEvent.fromCell(parseCellFromBase64(unwrapBody));
    val dexDeposit = GasPumpDexDepositEvent.fromCell(parseCellFromBase64(dexDepositBody));
    val state = GasPumpTradeStateEvent.fromCell(parseCellFromBase64(stateBody));

    expect(unwrap.from).toEqual(
        address("0:215B42289825AAD6077AAE8B781BC21ADFA9D591E27EC6CA75DABF519261EC64"),
    );
    expect(unwrap.jettonAmount).toEqual(291096576044617);
    expect(dexDeposit.amount0).toEqual(950000000000);
    expect(dexDeposit.amount1).toEqual(322034216187808503);
    expect(dexDeposit.amount2).toEqual(50000000000);
    expect(state.previousState).toEqual(1);
    expect(state.newState).toEqual(2);
}

get fun `test gaspump decodes real incoming and outgoing bodies`() {
    val buyBody = "te6cckEBAQEABwAACWzT5LDAwLhfiQ==";
    val transferNotificationBody = "te6cckEBAQEAOAAAbHNi0JwAAAAAAAAAAIBHgYadVlSveAA4WR6fN9JFeKgVVReQt6yHMHOrJ46Mdjp1ErpJLDhuylT9fFY=";
    val burnBody = "te6cckEBAQEAWQAArXvdl94AAAAAAAAAAHAQjANAKuSYAEK2hFEwS1WsDvVdFvA3hDW/U6sjxP2NlOu1fqMkw9jJAAhW0IomCWq1gd6rot4G8Ia36nVkeJ+xsp12r9RkmHsZIIoHyXc=";
    val stateUpdateBody = "te6cckEBAQEAJwAASSaIAL0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAUB4kpqr";
    val valueTransferBody = "te6cckEBAQEALAAAU1sixm1BpV6GKAGZp69w9zIVoEDte0PZMdMTaiib94/P8MpiaWGnGIl9Qa+K/Jc=";
    val minterRequestBody = "te6cckEBAQEAMAAAW4GdvpkAAAAAAAAAAIAbKFGszmPhov/5oF9Jh2QvNjwnyPumGKZd+9OUORU/kbDSveTk";
    val arbitrarySendBody = "te6cckEBAgEAmgABzZthg4nAD0KA39QNCwBOveU2CxaWYQb5RtaEoYK8MkWJh0c52JHwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC+vCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAkABAFsAAAADAAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQ2y4yog==";
    val dexTransitionBody = "te6cckEBAQEABgAACKfnvorKZJ7s";
    val dexConfigBody = "te6cckEBBAEAygACjbhGKt+AG1wqdOmxKXeGTpAzGaxNyeu+lNNaX0rZ0B+EyJauEaQQA/rXuwxA9ELkLxPh5xErgXmoELjIIjAHSv9G+zk1P962AQIBZ9VeRoYAAAAAAAAAAF3TBpnAAAgHoUBv6gaFgCde8psFi0swg3yja0JQwV4ZIsTDo5zsSPkDAGlA4QjWAIB6FAb+oGhYAnXvKbBYtLMIN8o2tCUMFeGSLEw6Oc7Ej4LumDTOAEAjwMNOqypXuQAdBd0waZwAgEeBhp1WVK94y9HCIA==";
    val auxiliaryDeployBody = "te6cckEBAQEABgAACLcN85IG1m56";
    val excessBody = "te6cckEBAQEADgAAGNUydtsAAAAAAAAAAPfBmNw=";
    val internalTransferBody = "te6cckEBAgEAXAABrReNRRkAAAAAAAAAAHcBw6IkGkGoAWJ18JuMltkUD8PfWj8CyPjzEIEIkJarDbYCbyOfgPVnABm2NQaFEbDpJcdadSMX4z9WnFuVV6pnBj+U9YsOJBisAwEAALqJ+sQ=";
    val jettonTransferBody = "te6cckEBAQEAWQAArg+KfqUAAAAAAAAAAHAQjANAKuSYAEK2hFEwS1WsDvVdFvA3hDW/U6sjxP2NlOu1fqMkw9jJAAhW0IomCWq1gd6rot4G8Ia36nVkeJ+xsp12r9RkmHsZAK7//rw=";
    val assignmentBody = "te6cckEBAQEAMAAAWzJ7K0oAAAAAAAAAAIAbKFGszmPhov/5oF9Jh2QvNjwnyPumGKZd+9OUORU/kbBZ1ziB";
    val dex03Body = "te6cckEBAQEAMAAAWwAAAAMAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABDuEbxV";
    val dex15Body = "te6cckEBAwEAkgABYwAAABUAAAAAAAAAAIAWJ18JuMltkUD8PfWj8CyPjzEIEIkJarDbYCbyOfgPVmgL68IBAQGvF41FGQAAAAAAAAAAgJaJ5J0f61CYAWJ18JuMltkUD8PfWj8CyPjzEIEIkJarDbYCbyOfgPVnADM09e4e5kK0CB2vaHsmOmJtRRN+8fn+GUxNLDTjES+oAwIAAJlJ+bM=";

    val buy = GasPumpMasterV1Buy.fromCell(parseCellFromBase64(buyBody));
    val transferNotification = GasPumpMessage7362d09c.fromCell(
        parseCellFromBase64(transferNotificationBody),
    );
    val burn = GasPumpBurnNotification.fromCell(parseCellFromBase64(burnBody));
    val stateUpdate = GasPumpMessage268800bd.fromCell(parseCellFromBase64(stateUpdateBody));
    val valueTransfer = GasPumpMessage5b22c66d.fromCell(parseCellFromBase64(valueTransferBody));
    val minterRequest = GasPumpMessage819dbe99.fromCell(parseCellFromBase64(minterRequestBody));
    val arbitrarySend = GasPumpMessage9b618389.fromCell(parseCellFromBase64(arbitrarySendBody));
    val dexTransitionCell = parseCellFromBase64(dexTransitionBody);
    val dexTransition = GasPumpMessageA7e7be8a.fromCell(dexTransitionCell);
    val dexConfig = GasPumpMessageB8462adf.fromCell(parseCellFromBase64(dexConfigBody));
    val auxiliaryDeployCell = parseCellFromBase64(auxiliaryDeployBody);
    val auxiliaryDeploy = GasPumpMessageB70df392.fromCell(auxiliaryDeployCell);
    val excess = GasPumpMessageD53276db.fromCell(parseCellFromBase64(excessBody));
    val internalTransfer = GasPumpJettonInternalTransfer.fromCell(
        parseCellFromBase64(internalTransferBody),
    );
    val jettonTransfer = GasPumpJettonTransfer.fromCell(parseCellFromBase64(jettonTransferBody));
    val assignment = GasPumpMinterAssignment.fromCell(parseCellFromBase64(assignmentBody));
    val dex03 = GasPumpDexMessage03.fromCell(parseCellFromBase64(dex03Body));
    val dex15 = GasPumpDexMessage15.fromCell(parseCellFromBase64(dex15Body));
    val forwardedDex03 = GasPumpDexMessage03.fromCell(arbitrarySend.body!);

    expect(buy.execute).toBeTrue();
    expect(transferNotification.queryId).toEqual(0);
    expect(transferNotification.amount).toEqual(322034216187808503);
    expect(transferNotification.sender).toEqual(
        address("kQAcLI9Pm-kivFQKqovIW9ZDmDnVk8dGOx06iV0klhw3ZdFm"),
    );
    expect(burn.queryId).toEqual(0);
    expect(burn.amount).toEqual(291096576044617);
    expect(burn.amount).toEqual(jettonTransfer.amount);
    expect(stateUpdate.newTradeState).toEqual(2);
    expect(valueTransfer.amount).toEqual(441837666);
    expect(valueTransfer.destination).toEqual(
        address("kQDM09e4e5kK0CB2vaHsmOmJtRRN-8fn-GUxNLDTjES-oCu8"),
    );
    expect(minterRequest.queryId).toEqual(0);
    expect(minterRequest.minterAddress).toEqual(assignment.minterAddress);
    expect(arbitrarySend.destination).toEqual(
        address("0:F4280DFD40D0B004EBDE5360B16966106F946D684A182BC324589874739D891F"),
    );
    expect(arbitrarySend.body).toBeNotNull();
    expect(dexTransition.toCell().hash()).toEqual(dexTransitionCell.hash());
    expect(dexConfig.address0 == dexConfig.address1).toBeFalse();
    expect(auxiliaryDeploy.toCell().hash()).toEqual(auxiliaryDeployCell.hash());
    expect(excess.queryId).toEqual(0);
    expect(internalTransfer.queryId).toEqual(0);
    expect(internalTransfer.amount).toEqual(31556233400001562);
    expect(internalTransfer.forwardTonAmount).toEqual(0);
    expect(jettonTransfer.queryId).toEqual(0);
    expect(assignment.queryId).toEqual(0);
    expect(dex03.queryId).toEqual(0);
    expect(forwardedDex03.destination).toEqual(dex03.destination);
    expect(dex15.queryId).toEqual(0);
    expect(dex15.forwardTonAmount).toEqual(100000000);
    expect(dex15.transfer.load().amount).toEqual(677965783812191497);
}
