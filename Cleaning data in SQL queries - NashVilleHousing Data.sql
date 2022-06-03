/* 
Cleaning data in SQL queries
*/

SELECT *
FROM PortfolioProject.dbo.NashVilleHousing

-- Standardize Date Format

SELECT Saledate, CONVERT(date,SaleDate) AS converted_saledate
FROM PortfolioProject.dbo.NashVilleHousing

ALTER TABLE PortfolioProject.dbo.NashVilleHousing
ADD SaleDateConverted date

UPDATE PortfolioProject.dbo.NashVilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

-- Veryfy whether the changes are reflected

SELECT SaleDateConverted, CONVERT(date,SaleDate) AS converted_saledate
FROM PortfolioProject.dbo.NashVilleHousing

-- Populate Property Address Data

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashVilleHousing
Where PropertyAddress is NULL

SELECT *
FROM PortfolioProject.dbo.NashVilleHousing
Where PropertyAddress is NULL

SELECT COUNT(*)
FROM PortfolioProject.dbo.NashVilleHousing
WHERE PropertyAddress is null

SELECT *
FROM PortfolioProject.dbo.NashVilleHousing
ORDER BY ParcelID
-- noticed from the data when the ParcelID is repeated the address is the same for the repeated ParcelID


SELECT a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashVilleHousing a
JOIN PortfolioProject.dbo.NashVilleHousing b
ON a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashVilleHousing a
JOIN PortfolioProject.dbo.NashVilleHousing b
ON a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Breaking Address Into Individual Columns (Address, City, State)

-- PropertyAddress Column

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashVilleHousing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashVilleHousing

ALTER TABLE PortfolioProject.dbo.NashVilleHousing
ADD PropertySplitAddress NVARCHAR(255),
    PropertySplitCity NVARCHAR(255)

UPDATE PortfolioProject.dbo.NashVilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1),
    PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.NashVilleHousing

--OwnerAddress Column

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.NashVilleHousing

ALTER TABLE PortfolioProject.dbo.NashVilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
	OwnerSplitCity NVARCHAR(255),
	OwnerSplitState NVARCHAR(255)

UPDATE PortfolioProject.dbo.NashVilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM PortfolioProject.dbo.NashVilleHousing

-- CHANGE Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(*) AS Count_YN
FROM PortfolioProject.dbo.NashVilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN  'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject.dbo.NashVilleHousing

UPDATE PortfolioProject.dbo.NashVilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN  'No'
						ELSE SoldAsVacant
						END

SELECT DISTINCT(SoldAsVacant), COUNT(*) AS Count_YN
FROM PortfolioProject.dbo.NashVilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- Remove Duplicates

WITH RowNum_Column AS
(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID,
				   PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference 
				   ORDER BY UniqueID) AS row_num
FROM PortfolioProject.dbo.NashVilleHousing
)

SELECT *
FROM RowNum_Column
WHERE row_num > 1

--Delete unused columns

SELECT *
FROM PortfolioProject.dbo.NashVilleHousing

ALTER TABLE PortfolioProject.dbo.NashVilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE PortfolioProject.dbo.NashVilleHousing
DROP COLUMN SaleDate

SELECT *
FROM PortfolioProject.dbo.NashVilleHousing

-- Data set Exploration

SELECT LandUse, COUNT(*) LandUse_Count
FROM PortfolioProject.dbo.NashVilleHousing
GROUP BY LandUse
ORDER BY 2 DESC

-- Year Column added
SELECT YEAR(SaleDateConverted) AS SaleDate_Year, COUNT(*) AS Year_Count
FROM PortfolioProject.dbo.NashVilleHousing
GROUP BY YEAR(SaleDateConverted)
ORDER BY 1

ALTER TABLE PortfolioProject.dbo.NashVilleHousing
ADD SaleDateYear INT

UPDATE PortfolioProject.dbo.NashVilleHousing
SET SaleDateYear = YEAR(SaleDateConverted) 

SELECT *
FROM PortfolioProject.dbo.NashVilleHousing

-- Average SalePrice Per LandUse
SELECT LandUse, ROUND(AVG(SalePrice),2)
FROM PortfolioProject.dbo.NashVilleHousing
GROUP BY LandUse
ORDER BY 2 DESC

