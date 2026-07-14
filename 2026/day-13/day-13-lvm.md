# AWS EBS and LVM (Logical Volume Manager) Guide

This guide demonstrates how to:

- View attached disks
- Create and attach EBS volumes
- Create Physical Volumes (PV)
- Create Volume Groups (VG)
- Create Logical Volumes (LV)
- Format and mount Logical Volumes
- Mount EBS volumes directly
- Extend Logical Volumes dynamically

---

# 1. List Available Disks

Use the following command to list all disks and partitions.

```bash
lsblk
```

Example:

```text
NAME         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
loop0          7:0    0   74M  1 loop /snap/core22/2411
loop1          7:1    0 28.2M  1 loop /snap/amazon-ssm-agent/13009
loop2          7:2    0 49.3M  1 loop /snap/snapd/26865
nvme0n1      259:0    0    8G  0 disk
├─nvme0n1p1  259:1    0  6.9G  0 part /
├─nvme0n1p13 259:2    0 1023M  0 part /boot
├─nvme0n1p14 259:3    0    4M  0 part
└─nvme0n1p15 259:4    0  106M  0 part /boot/efi
```

## Explanation

- **nvme0n1** → Primary/root disk
- **nvme0n1p1** → Root (`/`)
- **nvme0n1p13** → `/boot`
- **nvme0n1p15** → EFI partition

---

# 2. Check Disk Usage

Use:

```bash
df -h
```

Example:

```text
Filesystem       Size Used Avail Use% Mounted on
/dev/root        6.7G 2.3G 4.4G 34% /
/dev/nvme0n1p13 989M 96M 827M 11% /boot
/dev/nvme0n1p15 105M 6.3M 99M 7% /boot/efi
```

`df -h` displays mounted filesystems and their usage.

---

# 3. Create and Attach an EBS Volume

From the AWS Console:

1. Go to **EC2 → Elastic Block Store → Volumes**
2. Click **Create Volume**
3. Choose:
   - Size
   - Availability Zone (must match the EC2 instance)
4. Click **Create Volume**
5. Select the volume
6. Click **Actions → Attach Volume**
7. Select the EC2 instance

Example device name:

```
/dev/sdf
```

On Nitro instances, Linux translates it into:

```
nvme1n1
```

Verify:

```bash
lsblk
```

Example:

```text
nvme1n1 259:5 0 10G 0 disk
```

Attach additional volumes:

- 10 GB
- 12 GB
- 14 GB

Result:

```text
nvme1n1 10G
nvme2n1 12G
nvme3n1 14G
```

---

# 4. Logical Volume Manager (LVM)

LVM allows you to combine multiple physical disks into a single storage pool and create flexible logical volumes.

Hierarchy:

```
Physical Volume (PV)
        ↓
Volume Group (VG)
        ↓
Logical Volume (LV)
        ↓
Filesystem
        ↓
Mount Point
```

---

# 5. Start LVM

Run:

```bash
lvm
```

Initially:

```bash
pvs
```

No output appears because no Physical Volumes have been created yet.

---

# 6. Create Physical Volumes (PV)

Command:

```bash
pvcreate /dev/nvme1n1 /dev/nvme2n1 /dev/nvme3n1
```

Output:

```text
Physical volume "/dev/nvme1n1" successfully created.
Physical volume "/dev/nvme2n1" successfully created.
Physical volume "/dev/nvme3n1" successfully created.
```

List Physical Volumes:

```bash
pvs
```

Example:

```text
PV            VG   Fmt  Attr PSize  PFree
/dev/nvme1n1       lvm2 --- 10.00g 10.00g
/dev/nvme2n1       lvm2 --- 12.00g 12.00g
/dev/nvme3n1       lvm2 --- 14.00g 14.00g
```

---

# 7. Create a Volume Group (VG)

Create a volume group using two physical volumes:

```bash
vgcreate tws_vg /dev/nvme1n1 /dev/nvme2n1
```

Output:

```text
Volume group "tws_vg" successfully created
```

Verify:

```bash
vgs
```

Example:

```text
VG      #PV #LV VSize VFree
tws_vg    2   0 21.99g 21.99g
```

---

# 8. Create a Logical Volume (LV)

Create a 10 GB logical volume:

```bash
lvcreate -L 10G -n tws_lv tws_vg
```

Verify:

```bash
lvs
```

Output:

```text
LV      VG      LSize
tws_lv  tws_vg  10G
```

---

# 9. Display Detailed LVM Information

## Physical Volumes

```bash
pvdisplay
```

Displays:

- UUID
- Allocated space
- Free space
- Volume Group

---

## Volume Groups

```bash
vgdisplay
```

Displays:

- Total size
- Free space
- Number of PVs
- Number of LVs

---

## Logical Volumes

```bash
lvdisplay
```

Displays:

- LV path
- UUID
- Size
- Status
- Block device

---

# 10. Verify with lsblk

```bash
lsblk
```

Output:

```text
nvme2n1
└─tws_vg-tws_lv 10G lvm
```

Notice that `df -h` still does **not** show the logical volume because it has not been formatted or mounted.

---

# 11. Create a Mount Point

```bash
mkdir /mnt/tws_lv_mount
```

---

# 12. Format the Logical Volume

Create an ext4 filesystem:

```bash
mkfs.ext4 /dev/tws_vg/tws_lv
```

This prepares the logical volume for storing files.

---

# 13. Mount the Logical Volume

```bash
mount /dev/tws_vg/tws_lv /mnt/tws_lv_mount
```

Verify:

```bash
lsblk
```

```text
tws_vg-tws_lv
└── /mnt/tws_lv_mount
```

Also verify:

```bash
df -h
```

Example:

```text
/dev/mapper/tws_vg-tws_lv 9.8G 2.1M 9.3G 1% /mnt/tws_lv_mount
```

The logical volume is now mounted and ready for use.

---

# 14. Unmount the Logical Volume

```bash
umount /mnt/tws_lv_mount
```

Verify:

```bash
df -h
```

The mounted filesystem disappears.

To mount it again:

```bash
mount /dev/tws_vg/tws_lv /mnt/tws_lv_mount
```

---

# 15. Mount an EBS Volume Directly (Without LVM)

Instead of creating an LVM, an EBS volume can be formatted and mounted directly.

Create a mount point:

```bash
mkdir /mnt/tws_disk_mount
```

Format the disk:

```bash
mkfs -t ext4 /dev/nvme3n1
```

> **Note:** If the disk was previously initialized as an LVM Physical Volume, you may see:
>
> ```
> /dev/nvme3n1 contains a LVM2_member file system
> Proceed anyway? (y,N)
> ```
>
> Type `y` only if you want to overwrite the existing LVM metadata.

Mount the disk:

```bash
mount /dev/nvme3n1 /mnt/tws_disk_mount
```

Verify:

```bash
df -h
```

Example:

```text
/dev/nvme3n1 14G 2.1M 13G 1% /mnt/tws_disk_mount
```

---

# 16. Extend a Logical Volume

One of the biggest advantages of LVM is the ability to increase storage without recreating the filesystem.

Current size:

```text
10 GB
```

Increase by **5 GB**:

```bash
lvextend -L +5G /dev/tws_vg/tws_lv
```

Output:

```text
Logical volume successfully resized.
```

At this point:

- Logical Volume = **15 GB**
- Filesystem = **10 GB**

The filesystem still needs to be resized.

---

# 17. Resize the Filesystem

Run:

```bash
resize2fs /dev/tws_vg/tws_lv
```

Output:

```text
Filesystem is now 3932160 (4k) blocks long.
```

### Before resizing

```
+------------------------------+
| Logical Volume (15 GB)       |
| +--------------------------+ |
| | ext4 Filesystem (10 GB)  | |
| +--------------------------+ |
|      5 GB unused space       |
+------------------------------+
```

### After resizing

```
+------------------------------+
| Logical Volume (15 GB)       |
| +--------------------------+ |
| | ext4 Filesystem (15 GB)  | |
| +--------------------------+ |
+------------------------------+
```

---

# How `resize2fs` Works

`resize2fs` is a utility used to resize **ext2**, **ext3**, and **ext4** filesystems.

It can:

- Grow a filesystem
- Shrink a filesystem (usually while unmounted)

When run without specifying a size:

```bash
resize2fs /dev/tws_vg/tws_lv
```

it automatically:

1. Reads the size of the underlying logical volume.
2. Detects the new available space.
3. Expands the filesystem to occupy the full logical volume.

For ext4 filesystems, expanding can usually be performed **online**, meaning the filesystem can remain mounted during the resize.

---

# Verify the New Size

```bash
df -h
```

Example:

```text
/dev/mapper/tws_vg-tws_lv 15G 2.1M 14G 1% /mnt/tws_lv_mount
```

The logical volume and filesystem have now been successfully expanded.

---

# Summary

| Task | Command |
|------|---------|
| List disks | `lsblk` |
| Show disk usage | `df -h` |
| Create Physical Volume | `pvcreate` |
| List Physical Volumes | `pvs` |
| Create Volume Group | `vgcreate` |
| List Volume Groups | `vgs` |
| Create Logical Volume | `lvcreate` |
| List Logical Volumes | `lvs` |
| Display PV details | `pvdisplay` |
| Display VG details | `vgdisplay` |
| Display LV details | `lvdisplay` |
| Format Logical Volume | `mkfs.ext4` |
| Mount filesystem | `mount` |
| Unmount filesystem | `umount` |
| Extend Logical Volume | `lvextend` |
| Resize ext4 filesystem | `resize2fs` |

---

# LVM Workflow

```text
AWS EBS Volumes
        │
        ▼
+------------------+
| Physical Volumes |
| pvcreate         |
+------------------+
        │
        ▼
+------------------+
| Volume Group     |
| vgcreate         |
+------------------+
        │
        ▼
+------------------+
| Logical Volume   |
| lvcreate         |
+------------------+
        │
        ▼
+------------------+
| Filesystem       |
| mkfs.ext4        |
+------------------+
        │
        ▼
+------------------+
| Mount Point      |
| mount            |
+------------------+
        │
        ▼
     Store Data
```
