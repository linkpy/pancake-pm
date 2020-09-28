
local class = require 'nelua.utils.class'



local function is_node_in(l, n)
	for _, v in ipairs(l) do
		if v == n then return true end
	end
	return false
end

local function remove_node(l, n)
	for i, v in ipairs(l) do
		if v == n then
			table.remove(l, i)
			return
		end
	end
end




local Node = class()

function Node:_init(name, data)
	self.name = name
	self.data = data

	self.edges = {}

	self.resolved = false
	self.unresolved = false
end

function Node:add_edge(node)
	table.insert(self.edges, node)
	return self
end




local DepGraph = class()
DepGraph.Node = Node

function DepGraph:_init()
	self.root = nil
	self.nodes = {}

	self.on_visited = nil
	self.on_resolved = nil
end

function DepGraph:has_package(name)
	return not not self.nodes[name]
end

function DepGraph:add_package(name, data, root)
	if self.nodes[name] then
		error("Package '" .. name .. "' is already in the graph.")
	end

	self.nodes[name] = Node(name, data)

	if root then
		self.root = self.nodes[name]
	end

	return self.nodes[name]
end

function DepGraph:resolve()
	resolved = {}
	self:_visit(self.root, resolved, {})
	return resolved
end

function DepGraph:_visit(node, resolved)
	node.unresolved = true

	if self.on_visited then
		self.on_visited(node)
	end

	for _, edge in ipairs(node.edges) do
		if not edge.resolved then
			if edge.unresolved then
				error "Circular reference detected"
			end

			self:_visit(edge, resolved)
		end
	end

	table.insert(resolved, node)
	node.resolved = true
	node.unresolved = false

	if self.on_resolved then
		self.on_resolved(node)
	end
end




return DepGraph