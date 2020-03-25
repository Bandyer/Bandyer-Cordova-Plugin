package com.bandyer.cordova.plugin.utils

import java.io.IOException
import java.net.InetAddress
import java.net.Socket
import java.net.UnknownHostException
import java.security.SecureRandom
import java.util.*
import javax.net.ssl.SSLContext
import javax.net.ssl.SSLSocket
import javax.net.ssl.SSLSocketFactory
import javax.net.ssl.TrustManager

class TLSSocketFactoryCompat : SSLSocketFactory {

    private var internalSSLSocketFactory: SSLSocketFactory

    constructor() {
        val context = SSLContext.getInstance("TLS")
        context.init(null, null, null)
        internalSSLSocketFactory = context.socketFactory
    }

    constructor(tm: Array<TrustManager?>?) {
        val context = SSLContext.getInstance("TLS")
        context.init(null, tm, SecureRandom())
        internalSSLSocketFactory = context.socketFactory
    }

    override fun getDefaultCipherSuites(): Array<String> = internalSSLSocketFactory.defaultCipherSuites

    override fun getSupportedCipherSuites(): Array<String> = internalSSLSocketFactory.supportedCipherSuites

    @Throws(IOException::class)
    override fun createSocket(): Socket? = enableTLSOnSocket(internalSSLSocketFactory.createSocket())

    @Throws(IOException::class)
    override fun createSocket(s: Socket, host: String, port: Int, autoClose: Boolean): Socket? = enableTLSOnSocket(internalSSLSocketFactory.createSocket(s, host, port, autoClose))

    @Throws(IOException::class, UnknownHostException::class)
    override fun createSocket(host: String, port: Int): Socket? =
            enableTLSOnSocket(internalSSLSocketFactory.createSocket(host, port))

    @Throws(IOException::class, UnknownHostException::class)
    override fun createSocket(host: String, port: Int, localHost: InetAddress, localPort: Int): Socket? =
            enableTLSOnSocket(internalSSLSocketFactory.createSocket(host, port, localHost, localPort))

    @Throws(IOException::class)
    override fun createSocket(host: InetAddress, port: Int): Socket? =
            enableTLSOnSocket(internalSSLSocketFactory.createSocket(host, port))

    @Throws(IOException::class)
    override fun createSocket(address: InetAddress, port: Int, localAddress: InetAddress, localPort: Int): Socket? =
            enableTLSOnSocket(internalSSLSocketFactory.createSocket(address, port, localAddress, localPort))

    private fun enableTLSOnSocket(socket: Socket?): Socket? {
        if (socket !is SSLSocket) return null
        //Create list of supported protocols
        val supportedProtocols = ArrayList<String>()
        for (protocol in socket.enabledProtocols) {
            //Only add TLS protocols (don't want ot support older SSL versions)
            if (protocol.toUpperCase().contains("TLS")) supportedProtocols.add(protocol)
        }
        //Force add TLSv1.1 and 1.2 if not already added
        if (!supportedProtocols.contains("TLSv1.1")) supportedProtocols.add("TLSv1.1")
        if (!supportedProtocols.contains("TLSv1.2")) supportedProtocols.add("TLSv1.2")
        val protocolArray = supportedProtocols.toTypedArray()

        //enable protocols in our list
        socket.enabledProtocols = protocolArray
        return socket
    }
}