-- Create storage buckets
INSERT INTO storage.buckets (id, name, public) VALUES 
('tracks', 'tracks', true),
('track-images', 'track-images', true),
('category-images', 'category-images', true);

-- Storage policies for tracks bucket
CREATE POLICY "Tracks are publicly accessible" ON storage.objects
    FOR SELECT USING (bucket_id = 'tracks');

CREATE POLICY "Only admins can upload tracks" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'tracks' AND
        EXISTS (
            SELECT 1 FROM admins 
            WHERE id = auth.uid() AND is_active = true
        )
    );

CREATE POLICY "Only admins can update tracks" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'tracks' AND
        EXISTS (
            SELECT 1 FROM admins 
            WHERE id = auth.uid() AND is_active = true
        )
    );

CREATE POLICY "Only admins can delete tracks" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'tracks' AND
        EXISTS (
            SELECT 1 FROM admins 
            WHERE id = auth.uid() AND is_active = true
        )
    );

-- Storage policies for track-images bucket
CREATE POLICY "Track images are publicly accessible" ON storage.objects
    FOR SELECT USING (bucket_id = 'track-images');

CREATE POLICY "Only admins can upload track images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'track-images' AND
        EXISTS (
            SELECT 1 FROM admins 
            WHERE id = auth.uid() AND is_active = true
        )
    );

CREATE POLICY "Only admins can update track images" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'track-images' AND
        EXISTS (
            SELECT 1 FROM admins 
            WHERE id = auth.uid() AND is_active = true
        )
    );

CREATE POLICY "Only admins can delete track images" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'track-images' AND
        EXISTS (
            SELECT 1 FROM admins 
            WHERE id = auth.uid() AND is_active = true
        )
    );

-- Storage policies for category-images bucket
CREATE POLICY "Category images are publicly accessible" ON storage.objects
    FOR SELECT USING (bucket_id = 'category-images');

CREATE POLICY "Only admins can upload category images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'category-images' AND
        EXISTS (
            SELECT 1 FROM admins 
            WHERE id = auth.uid() AND is_active = true
        )
    );

CREATE POLICY "Only admins can update category images" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'category-images' AND
        EXISTS (
            SELECT 1 FROM admins 
            WHERE id = auth.uid() AND is_active = true
        )
    );

CREATE POLICY "Only admins can delete category images" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'category-images' AND
        EXISTS (
            SELECT 1 FROM admins 
            WHERE id = auth.uid() AND is_active = true
        )
    );
