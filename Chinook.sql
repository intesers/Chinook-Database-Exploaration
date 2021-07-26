/*How many tracks appeared 5 times, 4 times, 3 times....?*/

WITH appearances AS (SELECT COUNT(PlaylistTrack.PlaylistId) AS Number_of_Appearance
FROM Track
JOIN PlaylistTrack ON Track.TrackId = PlaylistTrack.TrackId
GROUP BY Track.TrackId,Track.Name)

SELECT appearances.Number_of_Appearance, COUNT(appearances.Number_of_Appearance) AS Number_of_Tracks
FROM appearances
GROUP BY appearances.Number_of_Appearance
ORDER BY appearances.Number_of_Appearance DESC;


/*Which album generated the most revenue?*/

SELECT Album.Title, SUM(InvoiceLine.UnitPrice) AS Revenue
FROM InvoiceLine
JOIN Track ON InvoiceLine.TrackId = Track.TrackId
JOIN Album ON Album.AlbumId = Track.AlbumId
GROUP BY Album.Title
ORDER BY Revenue DESC;


/*Which countries have the highest sales revenue? What percent of total revenue does each country make up*/

SELECT Invoice.BillingCountry, SUM(Invoice.Total) as Revenue, ROUND((SUM(Invoice.Total) * 100)/SUM(SUM(Invoice.Total)) OVER(), 2) as Percentages
FROM Invoice
GROUP BY Invoice.BillingCountry
ORDER BY Revenue DESC;


/*How many customers did each employee support, what is the average revenue for each sale, and what is their total sale?*/

SELECT (Employee.FirstName + ' ' + Employee.LastName) AS "Employee_Name", COUNT(Customer.SupportRepId) AS "Customers Supported", SUM(Invoice.Total) AS "Total sales"
FROM Employee
JOIN Customer ON Employee.EmployeeId = Customer.SupportRepId
JOIN Invoice ON Customer.SupportRepId = Invoice.CustomerId
GROUP BY (Employee.FirstName + ' ' + Employee.LastName)
ORDER BY SUM(Invoice.Total) DESC;

/*Do longer or shorter length albums tend to generate more revenue?*/

WITH sales_revenue AS (SELECT Invoice.InvoiceId, SUM(Invoice.Total) AS 'Revenue', InvoiceLine.TrackId AS 'Tracks' 
FROM Invoice
JOIN InvoiceLine ON InvoiceLine.InvoiceId = Invoice.InvoiceId
GROUP BY Invoice.InvoiceId, InvoiceLine.TrackId)

SELECT Album.Title, SUM((Track.Milliseconds)/60000) AS 'Length', SUM(sales_revenue.Revenue) AS 'Total Revenue' /*The SUM here sums the track revenue from the sales_revenue and groups them, thus the album revenue is generated*/
FROM Track
JOIN ALbum ON Track.AlbumId = Album.AlbumId
JOIN sales_revenue ON Track.TrackId = sales_revenue.Tracks
GROUP BY Album.Title, Album.AlbumId
ORDER BY SUM(sales_revenue.Revenue) DESC;


/*Is the number of times a track appear in any playlist a good indicator of sales?*/
WITH appearances AS (SELECT Track.TrackId, COUNT(PlaylistTrack.PlaylistId) AS Playlist_appearances
FROM Track
JOIN PlaylistTrack ON Track.TrackId = PlaylistTrack.TrackID
GROUP BY Track.TrackId)

SELECT appearances.Playlist_appearances, SUM(InvoiceLine.UnitPrice) AS Revenue
FROM InvoiceLine
JOIN appearances ON InvoiceLine.TrackId = appearances.TrackId
GROUP BY appearances.Playlist_appearances
ORDER BY Revenue DESC;
/*HINT: Calculate the sum of revenue based on appearance*/

/*7. How much revenue is generated each year, and what is its percent change from the previous year?*/

SELECT YEAR(Invoice.InvoiceDate) AS Years, SUM(Invoice.Total) AS Revenue,
ROUND((SUM(Invoice.Total)-LAG(SUM(Invoice.Total))OVER(ORDER BY YEAR(Invoice.InvoiceDate)))/(LAG(SUM(Invoice.Total))OVER(ORDER BY YEAR(Invoice.InvoiceDate)))*100, 2) AS Percent_change /*The LAG() function takes the value of the previous row, here I took the value of the previous row to calculate the percent change*/
FROM Invoice
GROUP BY YEAR(Invoice.InvoiceDate);