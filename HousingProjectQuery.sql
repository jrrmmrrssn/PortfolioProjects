/*

Cleaning Data in SQL Queries

*/

Select *
From HousingProject..NashvilleHousing

-- Standardize Date Format ------------------

Select SaleDateConverted, (CONVERT(Date, SaleDate))
From HousingProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Address Data -----------

Select *
From HousingProject..NashvilleHousing
--Where PropertyAddress is NULL
order by ParcelID

-- Select Duplicate ParcelID Where One is Null
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From HousingProject..NashvilleHousing a
Join HousingProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Update Null address with duplicate address
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From HousingProject..NashvilleHousing a
Join HousingProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out address into individual columns (address, city, state) ------------

Select PropertyAddress
from HousingProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
from HousingProject..NashvilleHousing

-- Create two new columns to seperate address values

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From HousingProject..NashvilleHousing

-- Do the same with owner address

Select OwnerAddress
from HousingProject..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From HousingProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) 

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
from HousingProject..NashvilleHousing

-- Change Y and N to Yes and No in 'sold as vacant' field ---------------

Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
from HousingProject..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, CASE When SoldAsVacant = 'y' THEN 'yes'
	   When SoldAsVacant = 'n' THEN 'no'
	   ELSE SoldAsVacant
	   END
from HousingProject..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'y' THEN 'yes'
	   When SoldAsVacant = 'n' THEN 'no'
	   ELSE SoldAsVacant
	   END

-- Remove Duplicates ------------------------------

WITH RowNumCTE AS (
select * ,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num


from HousingProject..NashvilleHousing
--order by ParcelID
)
--Select *
DELETE
From RowNumCTE
Where row_num > 1
--order by PropertyAddress


-- Delete Unused Columns -------------------------

Select *
From HousingProject..NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
