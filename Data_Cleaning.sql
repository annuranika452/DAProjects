Select *
From SQLProject..NashvilleHousing

--Standardize Date Format

Select SaleDate, CONVERT(Date, SaleDate) as SaleDateConverted
From SQLProject..NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

--populate property address data

Select *
From SQLProject..NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM SQLProject..NashvilleHousing a
JOIN SQLProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM SQLProject..NashvilleHousing a
JOIN SQLProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--breaking out address into individual columns (address, city, state)

Select PropertyAddress
From SQLProject..NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From SQLProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From SQLProject..NashvilleHousing

Select OwnerAddress
From SQLProject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From SQLProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From SQLProject..NashvilleHousing

--change Y and N to Yes and No in "sold as vacant" field

Select DISTINCT(SoldasVacant), COUNT(SoldasVacant)
From SQLProject..NashvilleHousing
Group by SoldasVacant
Order by 2

Select SoldasVacant,
CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
     WHEN SoldasVacant = 'N' THEN 'No'
	 ELSE SoldasVacant
	 END
From SQLProject..NashvilleHousing

Update NashvilleHousing 
SET SoldasVacant = CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
     WHEN SoldasVacant = 'N' THEN 'No'
	 ELSE SoldasVacant
	 END

--Remove Duplicates

WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
			  UniqueID
)row_num
From SQLProject..NashvilleHousing
)
--Select *
DELETE
From RowNumCTE
WHERE row_num >1
--ORDER BY ParcelID

--Delete Unused Columns

Select*
From SQLProject..NashvilleHousing

ALTER TABLE SQLProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE SQLProject..NashvilleHousing
DROP COLUMN SaleDate