--CLEANING DATA IN SQL QUERIES
SELECT *
FROM DataCleaning..NashvilleHousing

--Estandarize data format

SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM DataCleaning..NashvilleHousing

UPDATE DataCleaning.dbo.NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE DataCleaning.dbo.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE DataCleaning.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

--Populate Property Adress data	

SELECT *
FROM DataCleaning..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaning..NashvilleHousing a
JOIN DataCleaning..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaning..NashvilleHousing a
JOIN DataCleaning..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Breaking out Address into individual columns (Address, City, State)
--Property Address

SELECT PropertyAddress
FROM DataCleaning.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1	, LEN(PropertyAddress)) AS Address
FROM DataCleaning.dbo.NashvilleHousing

ALTER TABLE DataCleaning.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE DataCleaning.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE DataCleaning.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE DataCleaning.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM DataCleaning.dbo.NashvilleHousing

--Propety Owner

SELECT OwnerAddress
FROM DataCleaning.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM DataCleaning.dbo.NashvilleHousing

ALTER TABLE DataCleaning.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update DataCleaning.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE DataCleaning.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update DataCleaning.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE DataCleaning.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update DataCleaning.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM DataCleaning.dbo.NashvilleHousing

--Change Y and N to Yes and No in SoldAsVacant field

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaning.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM DataCleaning.dbo.NashvilleHousing

UPDATE DataCleaning.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM DataCleaning.dbo.NashvilleHousing

--Removing duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM DataCleaning.dbo.NashvilleHousing
)


SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

DELETE 
FROM RowNumCTE
WHERE row_num > 1


--Delete unused columns

SELECT *
FROM DataCleaning.dbo.NashvilleHousing


ALTER TABLE DataCleaning.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate