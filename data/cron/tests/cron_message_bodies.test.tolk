import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/cron.types"

const CRON_TRIGGER_DESTINATION = "0:4747F0203A0E06275083AFF2F637C30ED2B60D0CBDA37190A65AB8898578AE07"
const CRON_TRIGGER_REWARD_ADDRESS = "0:6263D0F7F77C9D1228B86F559817C0232F21FD187925B1EDAF2EC6EB82543E7E"

get fun `test decodes toncenter cron_trigger body`() {
    val txHash = "UgqiuESvrmL8OjCmmzQX+mv/4OQ1f2quGMjh5qjEuIE=";
    val txLt = "82015997000001";
    val bodyBoc = "te6cckEBAQEALAAAUyEUcC2ADEx6Hv7vk6JFFw3qswL4BGXkP6MPJLY9teXY3XBKh8/fQHr/8GETgH8=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = CronTrigger.fromCell(body);

    expect(decoded.rewardAddress).toEqual(address(CRON_TRIGGER_REWARD_ADDRESS));
    expect(decoded.salt).toEqual(4194555903);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("CRON_TRIGGER_DESTINATION={}", CRON_TRIGGER_DESTINATION);
    println("CRON_TRIGGER_TX={} LT={}", txHash, txLt);
}
