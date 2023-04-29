/**
 * Several batteries-included stream implementations ready for use
 */
module river.impls;

/** 
 * Socket stream
 */
public import river.impls.sock;

/** 
 * FD-based stream
 */
public import river.impls.fd;

/** 
 * Pipe-based stream
 */
public import river.impls.pipe;

/** 
 * `File`-based stream
 */
public import river.impls.file;