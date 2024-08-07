﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Health.HBSP.Integration.Common.Framework
{
    /// <summary>
    /// Extension methods for Container
    /// </summary>
    public static class ContainerExtensions
    {
        /// <summary>
        /// Registers an implementation type for the specified interface
        /// </summary>
        /// <typeparam name="T">Interface to register</typeparam>
        /// <param name="container">This container instance</param>
        /// <param name="type">Implementing type</param>
        /// <returns>IRegisteredType object</returns>
        public static Container.IRegisteredType Register<T>(this Container container, Type type)
            => container.Register(typeof(T), type);

        /// <summary>
        /// Registers an implementation type for the specified interface
        /// </summary>
        /// <typeparam name="TInterface">Interface to register</typeparam>
        /// <typeparam name="TImplementation">Implementing type</typeparam>
        /// <param name="container">This container instance</param>
        /// <returns>IRegisteredType object</returns>
        public static Container.IRegisteredType Register<TInterface, TImplementation>(this Container container)
            => container.Register(typeof(TInterface), typeof(TImplementation));

        /// <summary>
        /// Registers a factory function which will be called to resolve the specified interface
        /// </summary>
        /// <typeparam name="T">Interface to register</typeparam>
        /// <param name="container">This container instance</param>
        /// <param name="factory">Factory method</param>
        /// <returns>IRegisteredType object</returns>
        public static Container.IRegisteredType Register<T>(this Container container, Func<T> factory)
            => container.Register(typeof(T), () => factory());

        /// <summary>
        /// Registers a type
        /// </summary>
        /// <param name="container">This container instance</param>
        /// <typeparam name="T">Type to register</typeparam>
        /// <returns>IRegisteredType object</returns>
        public static Container.IRegisteredType Register<T>(this Container container)
            => container.Register(typeof(T), typeof(T));

        /// <summary>
        /// Returns an implementation of the specified interface
        /// </summary>
        /// <typeparam name="T">Interface type</typeparam>
        /// <param name="scope">This scope instance</param>
        /// <returns>Object implementing the interface</returns>
        public static T Resolve<T>(this Container.IScope scope) => (T)scope.GetService(typeof(T));
    }
}