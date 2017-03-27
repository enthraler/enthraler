using buddy.Should;

class EnthralerTest extends buddy.SingleSuite {
	public function new() {
		describe("Using Buddy", {
			it("should be a great testing experience", {
				true.should.be(true);
			});
		});
	}
}
