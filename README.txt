Link:
  <http://toolserver.org/~drh08/data/README.txt>

Data exported from u_drh08_geo_p MySQL database on toolserver.org
in tab-delimited format.

x_article_signatures.txt:
        Export of signature distance data (n=438,077 rows).
        Contains 438,077 articles in 85,389 locations.

        article_id      internal uuid for article
        lang            ISO 639-1 language code
        x,y             lon,lat of article
        nauthor_all     count of total contributors
        nauthor_anon    count of anonymous only contributors
        nedit_all       count of total contributions
        nedit_anon      count of anonymous only contributions
        d               signature distance
        page_id         mediawiki.page.page_id foreign key
        page_title      mediawiki.page.page_title value

x_contribs_by_month.txt:
        Export of contributions per month (n=4,019,134 rows).
        Contains 7,232,032 contributions from 30,349 locations during 2/02-8/08.

        year            year
        month           month (1-12)
        lang            ISO 639-1 language code
        article_id      internal uuid for article
        article_x       longitude for article
        article_y       latitude for article
        contrib_x       longitude for (anon) contributor
        contrib_y       latitude for (anon) contributor
        contrib_n       number of (anon) contributions from this x,y location

x_geoip_cache.txt:
        Export of IP geolocation results using GeoIP (n=2,641,056 rows).

        ip              IP address
        x               longitude
        y               latitude
        txt             description of location

Updated: 4 Dec 2010

For more information see:

  Hardy, Darren, 2010. Volunteered geographic information in Wikipedia.
  Thesis (PhD). Bren School of Environmental Science & Management,
  University of California, Santa Barbara, CA, USA.

