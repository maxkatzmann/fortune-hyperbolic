# The maximum disk radius that is considered in the experiments.
conf_maximumDiskRadius=20

# The number of different disk radii we consider.
conf_numberOfDiskRadii=10

# The slope factor adjusts how quickly the disk radii approach the
# maximum radius.  Since the disk volume expands exponentially with
# the radius, we expect numerically issues to arise rather suddenly.
# To account for this, we can choose a larger slope factor which leads
# to the radii approaching the maximum slower.
conf_slopeFactor=1

# The number of sites we want to have in the largest disk.  For all
# other disks the number of vertices will be scaled such that all
# disks are equally densly filled.
conf_numberOfSites=100000

# The number of samples per disk radius that are considered.
conf_numberOfSamples=20

# The maximum precision in bits we consider. This should be a multiple
# of 16 in [16, 256].
conf_maximumPrecision=128
