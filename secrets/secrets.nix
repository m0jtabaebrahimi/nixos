let

  mojodev-personal = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEistSJfghIvugM1DU5QWQUKLBqjjDPgtH0CRBvfJRNC";
  mojodev-work = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICqP2w5U796KDhYdXPQCOVOHxd8v17Vmghlv/OkRo5kq";
  sara = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGUMFO1muqIeXnpyAaqBrzlSgmR4WG2Ye/8Q7vOHeoXP";
  users = [ mojodev-personal mojodev-work sara ];
  mojodev = [ mojodev-personal mojodev-work ];

  main-pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJDyIr/FSz1cJdcoW69R+NrWzwGK/+3gJpqD1t8L2zE";
  asus-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzxQgondgEYcLpcPdJLrTdNgZ2gznOHCAxMdaceTUT1";
  iic-pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINgm5hEb8QUx0CQLn4pChqagFvt6ZUrptcSqHZ6JkhMS root@nixos";
  systems = [ main-pc asus-laptop iic-pc ];
in
{
  # For IIC-PC host (iic-vpn)
  "ppp-peers-iic-vpn.age".publicKeys = [ mojodev-work iic-pc ];
  "ppp-chap-secrets.age".publicKeys = [ mojodev-work iic-pc ];

  # For vm & laptop host (iic-vpn-ati)
  "ppp-peers-iic-vpn-ati.age".publicKeys = [ mojodev-personal main-pc ];
  "ppp-chap-secrets-iic-ati.age".publicKeys = [ mojodev-personal main-pc ];

  # mojodev user
  "mojodev-secrets.age".publicKeys = mojodev;

 # "secret1.age".publicKeys = users ++ systems;
}