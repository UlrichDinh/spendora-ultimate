insert into storage.buckets (id, name, public)
values ('receipts', 'receipts', true)
on conflict (id) do nothing;

create policy "Images are publicly accessible."
on storage.objects for select
using ( bucket_id = 'receipts' );

create policy "Authenticated users can upload images."
on storage.objects for insert
with check ( bucket_id = 'receipts' and auth.role() = 'authenticated' );

create policy "Users can update their own images."
on storage.objects for update
with check ( bucket_id = 'receipts' and auth.uid() = owner );

create policy "Users can delete their own images."
on storage.objects for delete
using ( bucket_id = 'receipts' and auth.uid() = owner );
