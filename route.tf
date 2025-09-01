resource "aws_route_table" "rtb" {
 vpc_id = aws_vpc.main.id
 route {
 cidr_block = "0.0.0.0/0"
 gateway_id = aws_internet_gateway.gw.id
 }
 tags = {
 Name = "MyRoute"
 }
}
resource "aws_route_table_association" "a_1" {
 subnet_id = aws_subnet.public_1.id
 route_table_id = aws_route_table.rtb.id
}
resource "aws_route_table_association" "a_2" {
 subnet_id = aws_subnet.public_2.id
 route_table_id = aws_route_table.rtb.id
}