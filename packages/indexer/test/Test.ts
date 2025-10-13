import assert from "assert";
import { 
  TestHelpers,
  AnchoredNFT_Approval
} from "generated";
const { MockDb, AnchoredNFT } = TestHelpers;

describe("AnchoredNFT contract Approval event tests", () => {
  // Create mock db
  const mockDb = MockDb.createMockDb();

  // Creating mock for AnchoredNFT contract Approval event
  const event = AnchoredNFT.Approval.createMockEvent({/* It mocks event fields with default values. You can overwrite them if you need */});

  it("AnchoredNFT_Approval is created correctly", async () => {
    // Processing the event
    const mockDbUpdated = await AnchoredNFT.Approval.processEvent({
      event,
      mockDb,
    });

    // Getting the actual entity from the mock database
    let actualAnchoredNFTApproval = mockDbUpdated.entities.AnchoredNFT_Approval.get(
      `${event.chainId}_${event.block.number}_${event.logIndex}`
    );

    // Creating the expected entity
    const expectedAnchoredNFTApproval: AnchoredNFT_Approval = {
      id: `${event.chainId}_${event.block.number}_${event.logIndex}`,
      owner: event.params.owner,
      approved: event.params.approved,
      tokenId: event.params.tokenId,
    };
    // Asserting that the entity in the mock database is the same as the expected entity
    assert.deepEqual(actualAnchoredNFTApproval, expectedAnchoredNFTApproval, "Actual AnchoredNFTApproval should be the same as the expectedAnchoredNFTApproval");
  });
});
