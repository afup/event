-- Reprise des meta descriptions d'easy-wp-meta-description (plugin retiré) dans Yoast SEO.
-- À exécuter une fois, AVANT l'activation de Yoast (sinon relancer ensuite
-- « Yoast SEO > Outils > Optimiser les données SEO » pour reconstruire ses index).
-- Idempotent : ne touche pas un contenu qui a déjà une meta description Yoast.

INSERT INTO wp_2021_postmeta (post_id, meta_key, meta_value)
SELECT pm.post_id, '_yoast_wpseo_metadesc', pm.meta_value
FROM wp_2021_postmeta pm
WHERE pm.meta_key = '_easy_wp_meta_description'
  AND TRIM(pm.meta_value) <> ''
  AND NOT EXISTS (
      SELECT 1 FROM wp_2021_postmeta y
      WHERE y.post_id = pm.post_id AND y.meta_key = '_yoast_wpseo_metadesc'
  );
