local module = {}

local wedge = Instance.new("WedgePart");
wedge.Anchored = true;
wedge.TopSurface = Enum.SurfaceType.Smooth;
wedge.BottomSurface = Enum.SurfaceType.Smooth;
wedge.CanTouch = false



--Triangle function by EgoMoose
function draw3dTriangle(a, b, c, parent, w1, w2)
	
	if not w1 then
		w1 = wedge:Clone()
	end
	if not w2 then
		w2 = wedge:Clone()
	end

	local ab, ac, bc = b - a, c - a, c - b;
	local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc);
	
	if (abd > acd and abd > bcd) then
		c, a = a, c;
	elseif (acd > bcd and acd > abd) then
		a, b = b, a;
	end
	
	ab, ac, bc = b - a, c - a, c - b;
	
	local right = ac:Cross(ab).unit;
	local up = bc:Cross(right).unit;
	local back = bc.unit;
	
	local height = math.abs(ab:Dot(up));
	
	w1.Size = Vector3.new(0, height, math.abs(ab:Dot(back)));
	w1.CFrame = CFrame.fromMatrix((a + b)/2, right, up, back);
	
	w2.Size = Vector3.new(0, height, math.abs(ac:Dot(back)));
	w2.CFrame = CFrame.fromMatrix((a + c)/2, -right, up, -back);

	w2.Parent = parent;
	w1.Parent = parent;
	
	return w1, w2;
end

--Fills the quadrant made by four vertices with triangles
function module.fillQuadrant(vert1, vert2, vert3, vert4, faceToReuse)
	local model = faceToReuse or Instance.new("Model")
	model.Name = "Face"

	local w1
	local w2
	local w3
	local w4

	if faceToReuse then
		w1 = faceToReuse:FindFirstChild("Triangle1")
		w2 = faceToReuse:FindFirstChild("Triangle2")
		w3 = faceToReuse:FindFirstChild("Triangle3")
		w4 = faceToReuse:FindFirstChild("Triangle4")
	end

	local t1, t2 = draw3dTriangle(vert1, vert2, vert3, model, w1, w2)
	local t3, t4 = draw3dTriangle(vert1, vert3, vert4, model, w3, w4)

	t1.Name = "Triangle1"
	t2.Name = "Triangle2"
	t3.Name = "Triangle3"
	t4.Name = "Triangle4"

	local color = BrickColor.Green()

	t1.BrickColor = color
	t2.BrickColor = color
	t3.BrickColor = color
	t4.BrickColor = color

	return model
end

return module