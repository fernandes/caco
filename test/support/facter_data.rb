module Support
  def self.facter_data
    {
      "aio_agent_version" => "6.10.1",
      "augeas" => {
        "version" => "1.12.0"
      },
      "disks" => {
        "sda" => {
          "model" => "VBOX HARDDISK",
          "size" => "9.90 GiB",
          "size_bytes" => 10632560640,
          "vendor" => "ATA"
        },
        "sr0" => {
          "model" => "CD-ROM",
          "size" => "1.00 GiB",
          "size_bytes" => 1073741312,
          "vendor" => "VBOX"
        },
        "sr1" => {
          "model" => "CD-ROM",
          "size" => "1.00 GiB",
          "size_bytes" => 1073741312,
          "vendor" => "VBOX"
        }
      },
      "dmi" => {
        "bios" => {
          "release_date" => "12/01/2006",
          "vendor" => "innotek GmbH",
          "version" => "VirtualBox"
        },
        "board" => {
          "manufacturer" => "Oracle Corporation",
          "product" => "VirtualBox",
          "serial_number" => "0"
        },
        "chassis" => {
          "type" => "Other"
        },
        "manufacturer" => "innotek GmbH",
        "product" => {
          "name" => "VirtualBox",
          "serial_number" => "0",
          "uuid" => "1FBCB283-FD6F-43C9-9CD2-511C63A261B2"
        }
      },
      "facterversion" => "3.14.5",
      "filesystems" => "btrfs,ext2,ext3,ext4,hfs,hfsplus,jfs,minix,msdos,ntfs,qnx4,ufs,vfat,xfs",
      "fips_enabled" => false,
      "hypervisors" => {
        "virtualbox" => {
          "revision" => "128414",
          "version" => "5.2.26"
        }
      },
      "identity" => {
        "gid" => 0,
        "group" => "root",
        "privileged" => true,
        "uid" => 0,
        "user" => "root"
      },
      "is_virtual" => true,
      "kernel" => "Linux",
      "kernelmajversion" => "4.9",
      "kernelrelease" => "4.9.0-8-amd64",
      "kernelversion" => "4.9.0",
      "load_averages" => {
        "15m" => 0.01,
        "1m" => 0.02,
        "5m" => 0.02
      },
      "memory" => {
        "swap" => {
          "available" => "377.72 MiB",
          "available_bytes" => 396070912,
          "capacity" => "12.56%",
          "total" => "432.00 MiB",
          "total_bytes" => 452980736,
          "used" => "54.27 MiB",
          "used_bytes" => 56909824
        },
        "system" => {
          "available" => "334.44 MiB",
          "available_bytes" => 350683136,
          "capacity" => "32.09%",
          "total" => "492.46 MiB",
          "total_bytes" => 516382720,
          "used" => "158.02 MiB",
          "used_bytes" => 165699584
        }
      },
      "mountpoints" => {
        "/" => {
          "available" => "4.40 GiB",
          "available_bytes" => 4725555200,
          "capacity" => "51.27%",
          "device" => "/dev/mapper/debian--9--vg-root",
          "filesystem" => "ext4",
          "options" => [
            "rw",
            "relatime",
            "errors=remount-ro",
            "data=ordered"
          ],
          "size" => "9.03 GiB",
          "size_bytes" => 9696514048,
          "used" => "4.63 GiB",
          "used_bytes" => 4970958848
        },
        "/boot" => {
          "available" => "198.96 MiB",
          "available_bytes" => 208625664,
          "capacity" => "15.45%",
          "device" => "/dev/sda1",
          "filesystem" => "ext2",
          "options" => [
            "rw",
            "relatime",
            "block_validity",
            "barrier",
            "user_xattr",
            "acl"
          ],
          "size" => "235.32 MiB",
          "size_bytes" => 246755328,
          "used" => "36.36 MiB",
          "used_bytes" => 38129664
        },
        "/dev" => {
          "available" => "234.79 MiB",
          "available_bytes" => 246198272,
          "capacity" => "0%",
          "device" => "udev",
          "filesystem" => "devtmpfs",
          "options" => [
            "rw",
            "nosuid",
            "relatime",
            "size=240428k",
            "nr_inodes=60107",
            "mode=755"
          ],
          "size" => "234.79 MiB",
          "size_bytes" => 246198272,
          "used" => "0 bytes",
          "used_bytes" => 0
        },
        "/dev/hugepages" => {
          "available" => "0 bytes",
          "available_bytes" => 0,
          "capacity" => "100%",
          "device" => "hugetlbfs",
          "filesystem" => "hugetlbfs",
          "options" => [
            "rw",
            "relatime"
          ],
          "size" => "0 bytes",
          "size_bytes" => 0,
          "used" => "0 bytes",
          "used_bytes" => 0
        },
        "/dev/mqueue" => {
          "available" => "0 bytes",
          "available_bytes" => 0,
          "capacity" => "100%",
          "device" => "mqueue",
          "filesystem" => "mqueue",
          "options" => [
            "rw",
            "relatime"
          ],
          "size" => "0 bytes",
          "size_bytes" => 0,
          "used" => "0 bytes",
          "used_bytes" => 0
        },
        "/dev/pts" => {
          "available" => "0 bytes",
          "available_bytes" => 0,
          "capacity" => "100%",
          "device" => "devpts",
          "filesystem" => "devpts",
          "options" => [
            "rw",
            "nosuid",
            "noexec",
            "relatime",
            "gid=5",
            "mode=620",
            "ptmxmode=000"
          ],
          "size" => "0 bytes",
          "size_bytes" => 0,
          "used" => "0 bytes",
          "used_bytes" => 0
        },
        "/dev/shm" => {
          "available" => "246.22 MiB",
          "available_bytes" => 258183168,
          "capacity" => "0.00%",
          "device" => "tmpfs",
          "filesystem" => "tmpfs",
          "options" => [
            "rw",
            "nosuid",
            "nodev"
          ],
          "size" => "246.23 MiB",
          "size_bytes" => 258191360,
          "used" => "8.00 KiB",
          "used_bytes" => 8192
        },
        "/run" => {
          "available" => "43.77 MiB",
          "available_bytes" => 45891584,
          "capacity" => "11.13%",
          "device" => "tmpfs",
          "filesystem" => "tmpfs",
          "options" => [
            "rw",
            "nosuid",
            "noexec",
            "relatime",
            "size=50428k",
            "mode=755"
          ],
          "size" => "49.25 MiB",
          "size_bytes" => 51638272,
          "used" => "5.48 MiB",
          "used_bytes" => 5746688
        },
        "/run/lock" => {
          "available" => "5.00 MiB",
          "available_bytes" => 5242880,
          "capacity" => "0%",
          "device" => "tmpfs",
          "filesystem" => "tmpfs",
          "options" => [
            "rw",
            "nosuid",
            "nodev",
            "noexec",
            "relatime",
            "size=5120k"
          ],
          "size" => "5.00 MiB",
          "size_bytes" => 5242880,
          "used" => "0 bytes",
          "used_bytes" => 0
        },
        "/run/rpc_pipefs" => {
          "available" => "0 bytes",
          "available_bytes" => 0,
          "capacity" => "100%",
          "device" => "sunrpc",
          "filesystem" => "rpc_pipefs",
          "options" => [
            "rw",
            "relatime"
          ],
          "size" => "0 bytes",
          "size_bytes" => 0,
          "used" => "0 bytes",
          "used_bytes" => 0
        },
        "/run/user/1000" => {
          "available" => "49.25 MiB",
          "available_bytes" => 51638272,
          "capacity" => "0%",
          "device" => "tmpfs",
          "filesystem" => "tmpfs",
          "options" => [
            "rw",
            "nosuid",
            "nodev",
            "relatime",
            "size=50428k",
            "mode=700",
            "uid=1000",
            "gid=1000"
          ],
          "size" => "49.25 MiB",
          "size_bytes" => 51638272,
          "used" => "0 bytes",
          "used_bytes" => 0
        },
        "/sys/fs/cgroup" => {
          "available" => "246.23 MiB",
          "available_bytes" => 258191360,
          "capacity" => "0%",
          "device" => "tmpfs",
          "filesystem" => "tmpfs",
          "options" => [
            "ro",
            "nosuid",
            "nodev",
            "noexec",
            "mode=755"
          ],
          "size" => "246.23 MiB",
          "size_bytes" => 258191360,
          "used" => "0 bytes",
          "used_bytes" => 0
        },
        "/vagrant" => {
          "available" => "197.34 GiB",
          "available_bytes" => 211890008064,
          "capacity" => "57.63%",
          "device" => "vagrant",
          "filesystem" => "vboxsf",
          "options" => [
            "rw",
            "nodev",
            "relatime"
          ],
          "size" => "465.72 GiB",
          "size_bytes" => 500068036608,
          "used" => "268.39 GiB",
          "used_bytes" => 288178028544
        }
      },
      "networking" => {
        "dhcp" => "10.0.2.2",
        "domain" => "box",
        "fqdn" => "monitor.box",
        "hostname" => "monitor",
        "interfaces" => {
          "enp0s3" => {
            "bindings" => [
              {
                "address" => "10.0.2.15",
                "netmask" => "255.255.255.0",
                "network" => "10.0.2.0"
              }
            ],
            "bindings6" => [
              {
                "address" => "fe80::a00:27ff:fedc:9012",
                "netmask" => "ffff:ffff:ffff:ffff::",
                "network" => "fe80::"
              }
            ],
            "dhcp" => "10.0.2.2",
            "ip" => "10.0.2.15",
            "ip6" => "fe80::a00:27ff:fedc:9012",
            "mac" => "08:00:27:dc:90:12",
            "mtu" => 1500,
            "netmask" => "255.255.255.0",
            "netmask6" => "ffff:ffff:ffff:ffff::",
            "network" => "10.0.2.0",
            "network6" => "fe80::"
          },
          "enp0s8" => {
            "bindings" => [
              {
                "address" => "10.0.0.30",
                "netmask" => "255.255.255.0",
                "network" => "10.0.0.0"
              }
            ],
            "bindings6" => [
              {
                "address" => "fe80::a00:27ff:fe2d:a759",
                "netmask" => "ffff:ffff:ffff:ffff::",
                "network" => "fe80::"
              }
            ],
            "ip" => "10.0.0.30",
            "ip6" => "fe80::a00:27ff:fe2d:a759",
            "mac" => "08:00:27:2d:a7:59",
            "mtu" => 1500,
            "netmask" => "255.255.255.0",
            "netmask6" => "ffff:ffff:ffff:ffff::",
            "network" => "10.0.0.0",
            "network6" => "fe80::"
          },
          "lo" => {
            "bindings" => [
              {
                "address" => "127.0.0.1",
                "netmask" => "255.0.0.0",
                "network" => "127.0.0.0"
              }
            ],
            "bindings6" => [
              {
                "address" => " =>:1",
                "netmask" => "ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff",
                "network" => " =>:1"
              }
            ],
            "ip" => "127.0.0.1",
            "ip6" => " =>:1",
            "mtu" => 65536,
            "netmask" => "255.0.0.0",
            "netmask6" => "ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff",
            "network" => "127.0.0.0",
            "network6" => " =>:1"
          }
        },
        "ip" => "10.0.2.15",
        "ip6" => "fe80::a00:27ff:fedc:9012",
        "mac" => "08:00:27:dc:90:12",
        "mtu" => 1500,
        "netmask" => "255.255.255.0",
        "netmask6" => "ffff:ffff:ffff:ffff::",
        "network" => "10.0.2.0",
        "network6" => "fe80::",
        "primary" => "enp0s3"
      },
      "os" => {
        "architecture" => "amd64",
        "distro" => {
          "codename" => "stretch",
          "description" => "Debian GNU/Linux 9.11 (stretch)",
          "id" => "Debian",
          "release" => {
            "full" => "9.11",
            "major" => "9",
            "minor" => "11"
          }
        },
        "family" => "Debian",
        "hardware" => "x86_64",
        "name" => "Debian",
        "release" => {
          "full" => "9.11",
          "major" => "9",
          "minor" => "11"
        },
        "selinux" => {
          "enabled" => false
        }
      },
      "partitions" => {
        "/dev/mapper/debian--9--vg-root" => {
          "filesystem" => "ext4",
          "mount" => "/",
          "size" => "9.24 GiB",
          "size_bytes" => 9919528960,
          "uuid" => "f44ae435-b996-41b8-a14d-d11cf4a1dc84"
        },
        "/dev/mapper/debian--9--vg-swap_1" => {
          "filesystem" => "swap",
          "size" => "432.00 MiB",
          "size_bytes" => 452984832,
          "uuid" => "05ad6605-284b-4e10-904c-7504248c8817"
        },
        "/dev/sda1" => {
          "filesystem" => "ext2",
          "mount" => "/boot",
          "partuuid" => "08490364-01",
          "size" => "243.00 MiB",
          "size_bytes" => 254803968,
          "uuid" => "36304cd9-c6eb-4779-81d4-fbfdcf51f640"
        },
        "/dev/sda2" => {
          "size" => "1.00 KiB",
          "size_bytes" => 1024
        },
        "/dev/sda5" => {
          "filesystem" => "LVM2_member",
          "partuuid" => "08490364-05",
          "size" => "9.66 GiB",
          "size_bytes" => 10374610944,
          "uuid" => "zsTZ7j-jIn1-R615-dSwC-Nw8P-tnXx-qhEKFe"
        }
      },
      "path" => "/opt/rbenv/shims:/opt/rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin",
      "processors" => {
        "count" => 1,
        "isa" => "unknown",
        "models" => [
          "Intel(R) Core(TM) i7-4870HQ CPU @ 2.50GHz"
        ],
        "physicalcount" => 1
      },
      "ruby" => {
        "platform" => "x86_64-linux",
        "sitedir" => "/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.5.0",
        "version" => "2.5.7"
      },
      "ssh" => {
        "ecdsa" => {
          "fingerprints" => {
            "sha1" => "SSHFP 3 1 8afeb371fb0c8345035e583111ed49eef2b21a3c",
            "sha256" => "SSHFP 3 2 3eba485145f851277207e12f777a6b7e694e4754b7972104f7bb0fffbc49c41c"
          },
          "key" => "AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLCy3rrmu1/A8gCgec43La3bjAWp07l9SKaPIvML6K9/SUcHSErb6dSINjnfy2I5qLyRG7s8X8/4eqgFAUJEzMo=",
          "type" => "ecdsa-sha2-nistp256"
        },
        "ed25519" => {
          "fingerprints" => {
            "sha1" => "SSHFP 4 1 230a125a211167d2d6f015631998697b140a2d56",
            "sha256" => "SSHFP 4 2 bd19f0304b6e0fb4d3e3e655807690e9f9eb3bf28a726236b53672d362a4d0d2"
          },
          "key" => "AAAAC3NzaC1lZDI1NTE5AAAAIDkV/jXzWPadvaberYICFqLCNbm07twuQS+BuhK7R6vV",
          "type" => "ssh-ed25519"
        },
        "rsa" => {
          "fingerprints" => {
            "sha1" => "SSHFP 1 1 22a4ac21f601b754e659bb18d078e7e2085b3e90",
            "sha256" => "SSHFP 1 2 561a2644d66379e4c7275c5580f0983b97c2f415493a7805c77402ceaf47913c"
          },
          "key" => "AAAAB3NzaC1yc2EAAAADAQABAAABAQCpfrKXgK9eGEKnQ3wZoPunsU9cVwG8qOEWwNTjGirKIPjvych+yAtACpSoIeZNAQ89cbAtGrLiVn5kvnmZTSqCdqM0nreTo3Oj74AhxCcOP2GInQImdRDK5maEvQYFd1OWyhTGjyLFvAOLMHjmOH0Z7kQCpVLJX0pVRfJkLsCIXFRhi90nqHoZE6gNKDb5MVr0nhThZ4zNjItnLFqfFvfwxnqpPb6oQr+SGeMYqsZres/YWQA+d2tSuMckIrs9BnNDELFXew1K3uiDasjzPsam0u9FEJWyIgY9wH7f42FOBcgmh00BKut1mMKf2D5m1NdSBp287ytttHIEsTXLRG1d",
          "type" => "ssh-rsa"
        }
      },
      "system_uptime" => {
        "days" => 2,
        "hours" => 49,
        "seconds" => 176831,
        "uptime" => "2 days"
      },
      "timezone" => "America/Sao_Paulo",
      "virtual" => "virtualbox"
    }
  end
end
