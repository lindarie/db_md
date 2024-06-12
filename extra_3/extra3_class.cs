using System;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

[Serializable]
[SqlUserDefinedAggregate(Format.UserDefined, IsInvariantToNulls = true, IsInvariantToDuplicates = false, IsInvariantToOrder = false, MaxByteSize = -1)]
public class KolonnuMaxSumma : IBinarySerialize
{
    private SqlInt32 sum;

    public void Init()
    {
        this.sum = 0;
    }

    public void Accumulate(SqlInt32 Value1, SqlInt32 Value2)
    {
        this.sum += (Value1 > Value2) ? Value1 : Value2;
    }


    public void Merge(KolonnuMaxSumma Group)
    {
        this.sum += Group.sum;
    }

    public SqlInt32 Terminate()
    {
        return this.sum;
    }

    public void Read(System.IO.BinaryReader r)
    {
        this.sum = r.ReadInt32();
    }

    public void Write(System.IO.BinaryWriter w)
    {
        w.Write(this.sum.Value);
    }
}
