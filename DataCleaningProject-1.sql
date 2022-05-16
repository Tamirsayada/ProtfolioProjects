Select * 
from CleaningData.dbo.MAIN

---------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

Select SaleDate, CONVERT(date,SaleDate)
from CleaningData..main

update main
SET SaleDate = CONVERT(date,SaleDate)

-- OR

ALTER TABLE main
add SaleDateConverted date

update main
SET SaleDateConverted = CONVERT(date,SaleDate)

---------------------------------------------------------------------------------------------------------------
-- Populate Property Address Data

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from CleaningData..main a
join CleaningData..main b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from CleaningData..main a
join CleaningData..main b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

---------------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns: Address, City, State

Select * 
from CleaningData.dbo.MAIN

Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from CleaningData.dbo.MAIN

ALTER TABLE main
add Property_Address nvarchar(255)

update main
SET Property_Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE main
add Property_City nvarchar(255)

update main
SET Property_City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select OwnerAddress,
PARSENAME(Replace (OwnerAddress,',','.'),3),
PARSENAME(Replace (OwnerAddress,',','.'),2),
PARSENAME(Replace (OwnerAddress,',','.'),1)
from CleaningData.dbo.MAIN

ALTER TABLE main
add owner_Address nvarchar(255)

update main
SET owner_Address = PARSENAME(Replace (OwnerAddress,',','.'),3)

ALTER TABLE main
add Owner_City nvarchar(255)

update main
SET Owner_City = PARSENAME(Replace (OwnerAddress,',','.'),2)

ALTER TABLE main
add Owner_state nvarchar(255)

update main
SET Owner_state = PARSENAME(Replace (OwnerAddress,',','.'),1)

---------------------------------------------------------------------------------------------------------------
-- Change Y & N to Yes & No in "Sold as Vacant" filed

Select SoldAsVacant,
case
when SoldAsVacant = 'N' then 'No'
when SoldAsVacant = 'Y' then 'YES'
else SoldAsVacant end
from CleaningData.dbo.MAIN

update main
set SoldAsVacant =
case
when SoldAsVacant = 'N' then 'No'
when SoldAsVacant = 'Y' then 'YES'
else SoldAsVacant end

---------------------------------------------------------------------------------------------------------------
--Delete Duplicates

WITH Row_numCTE AS(
Select *,
ROW_NUMBER() over(PARTITION by
							parcelid,
							propertyaddress,
							saleprice,
							saledateconverted,
							legalreference
							order by uniqueid)
							row_num
from CleaningData.dbo.MAIN
)

DELETE 
from Row_numCTE
where row_num >1

---------------------------------------------------------------------------------------------------------------
--Delete Unused Columns


Alter Table CleaningData.dbo.MAIN
drop Column owneraddress, propertyaddress,taxdistrict,SaleDate