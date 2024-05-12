select cont.name, count(distinct pubPub.dblp_key) from pub_data_publication pubPub, pub_data_authoraffiliation pubAutAff, pub_data_author pubAuth, pub_data_publication_authors
pubPubAut, publication pub, publications2 pub2, pub_data_affiliation pubAff, pub_data_country cont
where pubPub.id = pubPubAut.publication_id and -- Connect publication to pubdatapublicationauthors table
pubAutAff.id = pubPubAut.authoraffiliation_id -- This connects authoraffliation and publication authors
and pubAutAff.author_id = pubAuth.id -- Gets author (NOT SURE WHY THIS IS NEEDED)
and pubAutAff.affiliation_id = pubAff.id -- Connect affliation to publication table
and pubPub.dblp_key = pub.pubkey -- Connect geodblb and dblp
and pub2.pubid = pub.pubid -- Connect our pubs2 and pubs (as our pubs2 doesnt have pubkey, might want to change this in schema)
and pub2.venue= 'PODS' -- Select either sigmod or papers 
and cont.id = pubAff.country_Id -- Get country name from aff country id(We in theory don't need this and could get data from country id)
and pub2.year >= 2001 and pub2.year <= 2011 -- Only care about 2001 - 2011
group by cont.name; -- (This will be set to specific value for each of the queries but for now is easier for us to just see all to verify original q
