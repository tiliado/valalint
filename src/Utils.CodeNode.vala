namespace Linter.Utils.CodeNode {

public inline bool same_start(Vala.CodeNode node1, Vala.CodeNode node2) {
	return node1.source_reference.begin.pos == node2.source_reference.begin.pos;
}

} // namespace Linter.Utils.CodeNode
