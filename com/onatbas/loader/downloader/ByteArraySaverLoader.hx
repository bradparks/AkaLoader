package com.onatbas.loader.downloader;

import com.onatbas.loader.loaders.ExternalByteArrayLoader;
import com.onatbas.loader.event.LoaderEvent;
import com.onatbas.loader.downloader.BytearraySaver;
import com.onatbas.loader.loaders.ByteArrayLoader;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;
import com.onatbas.loader.loaders.IExternalLoader;
class ByteArraySaveLoader implements IExternalLoader<ByteArray>
{

    public var id(default, null):String;
    public var ready(default, null):Bool = false;

    private var saveAfterLoadRequired:Bool = false;
    private var dispatcher:EventDispatcher;

    private var loader:ExternalByteArrayLoader;
    private var saver:ByteArraySaver;

    private var state:String;


    public function addListener(type:String, listener:Dynamic -> Void):Void
    {
        dispatcher.addEventListener(type, listener);
    }

    public function removeListener(type:String, listener:Dynamic -> Void):Void
    {
        dispatcher.removeEventListener(type, listener);
    }

    public function disposeAll():Void
    {
        loader.disposeAll();
    }


    public function start():Void
    {
        loader.start();
    }


    public function canDeliver(deliverable:ExternalDeliverable<Dynamic>):Bool
    {
        return loader.canDeliver(deliverable);
    }

    public function deliver(deliverable:ExternalDeliverable<ByteArray>):Void
    {
        loader.deliver(deliverable);
    }

    public function new(id:String, path:String, url:String)
    {
        this.id = id;

        dispatcher = new EventDispatcher();

        saver = new BytearraySaver();
        saver.setPath(path);
        saver.setUrl(url);


        if (saver.isSaved())
        {
            loader = new ExternalByteArrayLoader(id, saver.getCompletePath());
            saveAfterLoadRequired = false;
        }
        else
        {
            loader = new ExternalByteArrayLoader(id, url);
            saveAfterLoadRequired = true;
        }

        loader.addListener(LoaderEvent.COMPLETE, handleComplete);
    }




    private function handleComplete(e:LoaderEvent):Void
    {
        ready = true;
        dispatcher.dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, this));
    }

    public function prepare():Void
    {
        loader.prepare();

        if (saveAfterLoadRequired)
        {
            saver.setData(loader.data);
            saver.save();
        }

    }

    public function getData():ByteArray
    {
        return loader.data;
    }

}