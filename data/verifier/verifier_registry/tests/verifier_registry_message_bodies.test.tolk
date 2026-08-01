import "@acton/fmt"
import "@acton/testing/expect"
import "../types/verifier_registry.types"

const ORBS_ID = 0x6aaf20fed58ba5e6db692909e78e5c5c6525e28d1cfa8bd22dc216729b4841b3
const VERIFIER_TON_ORG_ID = 0x7494b4c0aca9820e02a5024a9009a84321bd379467c8be09c9d25a26f18d0b87

get fun `test decodes real verifier registry forward message`() {
    val body = parseCellFromBase64(
        "te6ccgECBQEAAXAAAhh1IXdYWruMqxisTrcBAgHNdJS0wKypgg4CpQJKkAmoQyG9N5RnyL4JydJaJvGNC4dqPQlvgAaA+y5HCYSiixWzlfCjX7PiYYmr5Ic6uyQhPFgevnWy0AP4ElJVQm+K539C/tiZ93erNd2uZXnbl7dgPNZCgcgCIgMAwG/IzFZJw/9DX3nmVTcBDihghqMnVupGqs7h8Dx2YPerbs1ndHf6g+ME00xTgqjsqxG0XrmEE5BUQKOMPonHgQMcrz343AfCU40R/4f2bOZV9+IwGI8Oe667woEbUOWZdwGYAAAD6lq7jKsYrE63dJS0wKypgg4CpQJKkAmoQyG9N5RnyL4JydJaJvGNC4c4Wl8N24QcF91RijJ8Mi19CY6Rx5XrmhUv6b5c0g5AyQQAhgFpcGZzOi8vYmFma3JlaWdxa2ZtZWJqY2J0aGthYmxrZWt2dGN4NXF3ajJ5eGJ0aHhsYmRzdGgydGJsNWZic3Fkbnk=",
    );
    val decoded = VerifierRegistryForwardMessage.fromCell(body);
    expect(decoded.queryId).toEqual(6537973950539648695);

    val message = decoded.msg.load();
    expect(message.verifierId).toEqual(VERIFIER_TON_ORG_ID);
    expect(message.validUntil).toEqual(1782385007);
    expect(message.sourceAddr.castToInternal()).toEqual(
        address("0:3407d972384c251458ad9caf851afd9f130c4d5f2439d5d92109e2c0f5f3ad96"),
    );
    expect(message.targetAddr.castToInternal()).toEqual(
        address("0:fe049495509be2b9dfd0bfb6267dddeacd776b995e76e5edd80f3590a0720088"),
    );
    expect(message.msg.beginParse().preloadUint(32)).toEqual(0x000003ea);

    val signature = decoded.signatures.load();
    expect(
        signature.pubKey,
    ).toEqual(0x1caf3df8dc07c2538d11ff87f66ce655f7e230188f0e7baebbc2811b50e59977);
    expect(signature.next.remainingBitsCount()).toEqual(0);
    expect(signature.next.remainingRefsCount()).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test decodes real verifier registry update`() {
    val body = parseCellFromBase64(
        "te6ccgEBCAEA0AADW2AC1hoAAAAAAAAAAGqvIP7Vi6Xm22kpCeeOXFxlJeKNHPqL0i3CFnKbSEGzAsABAgMCASAEBQAQb3Jicy5jb20AIGh0dHBzOi8vb3Jicy5jb20AS7/860ZkeluWiK7t4oq73Uf0wVqx+StWtx9Cn9k6Yd4miwGBgYHAAgN6oAYHAEm+n48lFRPPHyWtiIFqTY48+jvUwvH7RaEsG/gyNR7xTPAwMDBIAEm+n1nGRqMDiNIEx2ckz4U19rN4gZzEnarDaiWAljY9AOAwMDBY",
    );
    val decoded = VerifierRegistryUpdateVerifier.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.verifierId).toEqual(ORBS_ID);
    expect(decoded.settings.multiSigThreshold).toEqual(2);
    expect(decoded.settings.pubKeyEndpoints.isEmpty()).toBeFalse();
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test decodes real verifier registry outgoing bodies`() {
    val forwardedBody = parseCellFromBase64(
        "te6cckEBBAEAugACAAECAEB0lLTArKmCDgKlAkqQCahDIb03lGfIvgnJ0lom8Y0LhwGYAAAD6uFbJ35J8s5HdJS0wKypgg4CpQJKkAmoQyG9N5RnyL4JydJaJvGNC4fpNOQHNTtH/iDxh0pKjetqDlyufQhAfPkn3DSr2y9LOgMAhgFpcGZzOi8vYmFma3JlaWRwZ2Rzazd3NnFtbnB0Znl2aHFqb2g2dXYzbm5xN2ltdzJ2cjRkcmxrNHNqNWZqYnB3a3VNikCf",
    );
    val forwarded = VerifierRegistryForwardedEnvelope.fromCell(forwardedBody);
    expect(forwarded.verifierIdentity.load().verifierId).toEqual(VERIFIER_TON_ORG_ID);
    expect(forwarded.payload.beginParse().preloadUint(32)).toEqual(0x000003ea);
    expect(forwarded.toCell().hash()).toEqual(forwardedBody.hash());

    val commentBody = parseCellFromBase64(
        "te6cckEBAQEANAAAZAAAAABZb3Ugd2VyZSBzdWNjZXNzZnVsbHkgcmVnaXN0ZXJlZCBhcyBhIHZlcmlmaWVyM1VxTQ==",
    );
    val comment = VerifierRegistryTextComment.fromCell(commentBody);
    expect(comment.text.remainingBitsCount()).toEqual(368);
    expect(comment.text.remainingRefsCount()).toEqual(0);
    expect(comment.toCell().hash()).toEqual(commentBody.hash());
}
