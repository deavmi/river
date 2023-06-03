module river.core.peakable;

/** 
 * A stream which implements `Peakable` means that one
 * can do a read in a manner which copies the length of
 * data requested into a buffer but without removing it
 * from the `Stream`'s underlying buffer
 */
public interface Peakable
{
    
}