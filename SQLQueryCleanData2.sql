SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
order by ParcelID

-- Standardize Date Format
ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE

SELECT SaleDate
FROM PortfolioProject.dbo.NashvilleHousing

--Populate Property Address Data

SELECT a.ParcelID, a. PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a. PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress=ISNULL(a. PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out Property address into individual columns(Address,City,State)
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1) as Address
,
SUBSTRING(PropertyAddress,CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress)) as City

FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress =SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

--Breaking out Owner address into individual columns(Address,City,State)

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing
where OwnerAddress is not null

SELECT 
PARSENAME(replace(owneraddress, ',','.'),3)
,PARSENAME(replace(owneraddress, ',','.'),2)
,PARSENAME(replace(owneraddress, ',','.'),1)
FROM PortfolioProject.dbo.NashvilleHousing
order by ParcelID

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(owneraddress, ',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace(owneraddress, ',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(owneraddress, ',','.'),1)

--Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT SOLDASVACANT
FROM PortfolioProject.dbo.NashvilleHousing

SELECT SOLDASVACANT
, (
	CASE WHEN SoldAsVacant = 'N' THEN 'No'
	
	WHEN SoldAsVacant ='Y' THEN 'Yes'
	ELSE SoldAsVacant
	 END)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant ='Y' THEN 'Yes'
	ELSE SoldAsVacant
	END

--Remove duplicates
WITH RowNumCTE AS(
SELECT *,ROW_NUMBER()OVER(PARTITION BY ParcelID,	
							 PropertyAddress,Saleprice,saledate, legalreference
							 order by uniqueid) as rownumber
FROM PortfolioProject.dbo.NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE rownumber>1
Order by PropertyAddress

--Delete unused columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress,OwnerAddress,Taxdistrict


