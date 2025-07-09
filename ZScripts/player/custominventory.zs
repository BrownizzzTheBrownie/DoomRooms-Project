class GridInventory
{
    static const int Width = 4;
    static const int Height = 4;

    // Each slot holds an item ID (or 0 for empty)
    int items[Width * Height];

    void Init()
    {
        for (int i = 0; i < Width * Height; i++)
            items[i] = 0; // Empty slot
    }

    int GetItem(int x, int y)
    {
        return items[y * Width + x];
    }

    void SetItem(int x, int y, int itemID)
    {
        items[y * Width + x] = itemID;
    }
}
